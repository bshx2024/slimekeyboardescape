# Cloudflare Browser Rendering Screenshot Capture Script
param (
    [string]$TargetUrl = "https://5515b0a5-cf28-4513-8a95-588b206fb79f.gdn.poki.com/372ecfd9-73a1-4190-8e77-1639db42ac1c/index.html",
    [string]$OutputFile = "assets/images/gameplay-showcase-1.jpg",
    [int]$Width = 1280,
    [int]$Height = 720,
    [string]$ApiToken = ""
)

# Load local config if present
$ConfigPath = Join-Path $PSScriptRoot "config.ps1"
if (Test-Path $ConfigPath) {
    . $ConfigPath
}

if (-not $ApiToken) {
    $ApiToken = $env:CLOUDFLARE_API_TOKEN
}

if (-not $ApiToken) {
    Write-Host "Error: CLOUDFLARE_API_TOKEN is not set. Please set \$env:CLOUDFLARE_API_TOKEN or define it in scripts/config.ps1" -ForegroundColor Red
    exit 1
}

$AccountId = "a9246b06d96e713031083e5a08343901"
$ApiUrl = "https://api.cloudflare.com/client/v4/accounts/$AccountId/browser-rendering/screenshot"

Write-Host "Connecting to Cloudflare Browser Rendering API..." -ForegroundColor Cyan
Write-Host "Target URL: $TargetUrl" -ForegroundColor Yellow

$Headers = @{
    "Authorization" = "Bearer $ApiToken"
    "Content-Type"  = "application/json"
}

$Body = @{
    "url" = $TargetUrl
    "viewport" = @{
        "width" = $Width
        "height" = $Height
    }
} | ConvertTo-Json

# Ensure destination directory exists
$OutputDir = Split-Path -Parent $OutputFile
if ($OutputDir -and !(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

try {
    Write-Host "Capturing screenshot ($Width x $Height)..." -ForegroundColor Cyan
    Invoke-RestMethod -Uri $ApiUrl -Method Post -Headers $Headers -Body $Body -OutFile $OutputFile
    Write-Host "Success! Screenshot saved to: $OutputFile" -ForegroundColor Green
} catch {
    Write-Host "Error capturing screenshot: $_" -ForegroundColor Red
}
