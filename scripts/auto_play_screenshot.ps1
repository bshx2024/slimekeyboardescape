# Automated Game Player & Screenshot Capture via Chrome CDP
param (
    [string]$TargetUrl = "https://playgama.com/export/game/1-speed-keyboard-escape-obby",
    [string]$OutputDir = "assets/images"
)

$ChromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (!(Test-Path $ChromePath)) {
    $ChromePath = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
}

if (!(Test-Path $ChromePath)) {
    Write-Host "Error: Chrome binary not found." -ForegroundColor Red
    exit 1
}

Write-Host "Launching Headless Chrome with Remote Debugging (Port 9222)..." -ForegroundColor Cyan

# Ensure output directory exists
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Kill any existing Chrome on port 9222
Get-Process chrome -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*9222*" } | Stop-Process -Force -ErrorAction SilentlyContinue

# Start Chrome in background
$ChromeProcess = Start-Process -FilePath $ChromePath -ArgumentList "--headless=new", "--remote-debugging-port=9222", "--window-size=1280,720", "--disable-gpu", "--no-sandbox", "`"$TargetUrl`"" -PassThru

# Wait for Chrome CDP port to become active
$CdpUrl = "http://127.0.0.1:9222/json"
$Connected = $false
for ($i = 0; $i -lt 15; $i++) {
    Start-Sleep -Milliseconds 500
    try {
        $Json = Invoke-RestMethod -Uri $CdpUrl -ErrorAction Stop
        if ($Json -and $Json.Count -gt 0) {
            $Connected = $true
            break
        }
    } catch {}
}

if (!$Connected) {
    Write-Host "Failed to connect to Chrome CDP." -ForegroundColor Red
    if ($ChromeProcess -and !$ChromeProcess.HasExited) { Stop-Process -Id $ChromeProcess.Id -Force }
    exit 1
}

$WsUrl = $Json[0].webSocketDebuggerUrl
Write-Host "Connected to Chrome CDP WebSocket: $WsUrl" -ForegroundColor Green

# Setup WebSocket Client
Add-Type -Assembly "System.Net.Http"
$ClientWs = New-Object System.Net.WebSockets.ClientWebSocket
$CancellationToken = [System.Threading.CancellationToken]::None
$ClientWs.ConnectAsync([Uri]$WsUrl, $CancellationToken).Wait()

$Script:MsgId = 1

function Send-CdpCommand {
    param (
        [string]$Method,
        [hashtable]$Params = @{}
    )
    $Script:MsgId++
    $Cmd = @{
        id = $Script:MsgId
        method = $Method
        params = $Params
    } | ConvertTo-Json -Depth 5 -Compress

    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Cmd)
    $Segment = [ArraySegment[byte]]::new($Bytes)
    $ClientWs.SendAsync($Segment, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $CancellationToken).Wait()

    # Receive response buffer
    $RecvBuffer = New-Object byte[] 524288
    $RecvSegment = [ArraySegment[byte]]::new($RecvBuffer)
    $Result = $ClientWs.ReceiveAsync($RecvSegment, $CancellationToken).Result
    $ResponseJson = [System.Text.Encoding]::UTF8.GetString($RecvBuffer, 0, $Result.Count)
    return $ResponseJson | ConvertFrom-Json
}

function Save-CdpScreenshot {
    param (
        [string]$Filename
    )
    Write-Host "Capturing CDP Screenshot: $Filename..." -ForegroundColor Yellow
    $Script:MsgId++
    $Cmd = @{
        id = $Script:MsgId
        method = "Page.captureScreenshot"
        params = @{ format = "jpeg"; quality = 90 }
    } | ConvertTo-Json -Compress

    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Cmd)
    $Segment = [ArraySegment[byte]]::new($Bytes)
    $ClientWs.SendAsync($Segment, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $CancellationToken).Wait()

    # Read complete screenshot buffer
    $Ms = New-Object System.IO.MemoryStream
    $RecvBuffer = New-Object byte[] 65536
    $RecvSegment = [ArraySegment[byte]]::new($RecvBuffer)
    
    do {
        $Res = $ClientWs.ReceiveAsync($RecvSegment, $CancellationToken).Result
        $Ms.Write($RecvBuffer, 0, $Res.Count)
    } while (!$Res.EndOfMessage)

    $ResponseStr = [System.Text.Encoding]::UTF8.GetString($Ms.ToArray())
    $Obj = $ResponseStr | ConvertFrom-Json
    if ($Obj.result -and $Obj.result.data) {
        $ImageBytes = [Convert]::FromBase64String($Obj.result.data)
        [System.IO.File]::WriteAllBytes($Filename, $ImageBytes)
        Write-Host "Saved: $Filename" -ForegroundColor Green
    } else {
        Write-Host "Failed to capture screenshot data for $Filename" -ForegroundColor Red
    }
}

try {
    # 1. Wait for Game Title & Loading Screen
    Write-Host "Step 1: Waiting for Game Load..." -ForegroundColor Cyan
    Start-Sleep -Seconds 3
    Save-CdpScreenshot (Join-Path $OutputDir "gameplay-showcase-1.jpg")

    # 2. Simulate Click Center to Start Game Play
    Write-Host "Step 2: Simulating Mouse Click to Play Game..." -ForegroundColor Cyan
    Send-CdpCommand "Input.dispatchMouseEvent" @{ type = "mousePressed"; x = 640; y = 360; button = "left"; clickCount = 1 }
    Send-CdpCommand "Input.dispatchMouseEvent" @{ type = "mouseReleased"; x = 640; y = 360; button = "left"; clickCount = 1 }
    Start-Sleep -Seconds 3
    Save-CdpScreenshot (Join-Path $OutputDir "showcase-2.jpg")

    # 3. Simulate Key Press (W & Space Bar to Run and Jump)
    Write-Host "Step 3: Simulating Keyboard Controls (KeyW & Space Jump)..." -ForegroundColor Cyan
    Send-CdpCommand "Input.dispatchKeyEvent" @{ type = "keyDown"; key = "w"; code = "KeyW" }
    Send-CdpCommand "Input.dispatchKeyEvent" @{ type = "keyDown"; key = " "; code = "Space" }
    Start-Sleep -Seconds 2
    Send-CdpCommand "Input.dispatchKeyEvent" @{ type = "keyUp"; key = " "; code = "Space" }
    Start-Sleep -Seconds 2
    Save-CdpScreenshot (Join-Path $OutputDir "showcase-3.jpg")

    # 4. Simulate Steering Left/Right
    Write-Host "Step 4: Steering & Sprinting..." -ForegroundColor Cyan
    Send-CdpCommand "Input.dispatchKeyEvent" @{ type = "keyDown"; key = "a"; code = "KeyA" }
    Start-Sleep -Seconds 1
    Send-CdpCommand "Input.dispatchKeyEvent" @{ type = "keyUp"; key = "a"; code = "KeyA" }
    Send-CdpCommand "Input.dispatchKeyEvent" @{ type = "keyDown"; key = "d"; code = "KeyD" }
    Start-Sleep -Seconds 2
    Send-CdpCommand "Input.dispatchKeyEvent" @{ type = "keyUp"; key = "d"; code = "KeyD" }
    Send-CdpCommand "Input.dispatchKeyEvent" @{ type = "keyUp"; key = "w"; code = "KeyW" }
    Save-CdpScreenshot (Join-Path $OutputDir "showcase-4.jpg")

} finally {
    if ($ClientWs.State -eq [System.Net.WebSockets.WebSocketState]::Open) {
        $ClientWs.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "Done", $CancellationToken).Wait()
    }
    if ($ChromeProcess -and !$ChromeProcess.HasExited) {
        Stop-Process -Id $ChromeProcess.Id -Force -ErrorAction SilentlyContinue
    }
    Write-Host "Automated Game Player & Capture Finished!" -ForegroundColor Green
}
