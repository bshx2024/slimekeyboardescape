# PowerShell script to clean spam backlinks and generate dual-sheet Excel report
$inputCsv = 'C:\Users\69444\Downloads\pokerogue.cc-backlinks.csv'
$validCsv = 'f:\旅行携带资料\Games\slimekeyboardescape\classified_valid_backlinks.csv'
$spamCsv  = 'f:\旅行携带资料\Games\slimekeyboardescape\classified_spam_backlinks.csv'
$outputXlsx = 'f:\旅行携带资料\Games\slimekeyboardescape\classified_clean_backlinks.xlsx'

if (-not (Test-Path $inputCsv)) {
    Write-Error "Input CSV not found at $inputCsv"
    exit 1
}

$data = Import-Csv -Path $inputCsv -Encoding UTF8

$validList = @()
$spamList  = @()

foreach ($row in $data) {
    $ascore     = [int]($row.'Page ascore')
    $sourceTitle = [string]($row.'Source title')
    $sourceUrl   = [string]($row.'Source url')
    $targetUrl   = [string]($row.'Target url')
    $anchor      = [string]($row.'Anchor')
    $extLinks    = [int]($row.'External links')
    $isNofollow  = [string]($row.'Nofollow')
    
    $domain = ""
    if ($sourceUrl -match "https?://([^/]+)") {
        $domain = $matches[1]
    }

    $isSpam = $false
    $spamReason = ""

    # Rule 1: Telegram Spam Ads
    if ($anchor -like "*TG @*" -or $anchor -like "*TELEGRAM*" -or $sourceTitle -like "*TG @*" -or $sourceTitle -like "*TELEGRAM*" -or $domain -like "*seol.store*") {
        $isSpam = $true
        $spamReason = "Telegram 批量卖外链广告/电报群叫卖农场"
    }
    # Rule 2: High External Links + Low AS (Link Farm)
    elseif ($extLinks -gt 200 -and $ascore -lt 10) {
        $isSpam = $true
        $spamReason = "垃圾链接农场 (出站链接数高达 $extLinks 条，AS 仅 $ascore 分)"
    }
    # Rule 3: Search Engine SERP Caches
    elseif ($domain -like "*search.yahoo.com*" -or $domain -like "*google.com*" -or $domain -like "*bing.com*") {
        $isSpam = $true
        $spamReason = "搜索引擎 SERP 结果页，并非真实外部网站"
    }
    # Rule 4: Subdomain Parasite / Hack Links
    elseif ($domain -like "*.alpinelinux.org*" -or $domain -like "*.eden-court.co.uk*" -or $domain -like "*.readingrights.org*" -or $domain -like "*.existentialcomics.com*") {
        $isSpam = $true
        $spamReason = "黑帽寄生虫 / 劫持高权重机构二级域名"
    }
    # Rule 5: Blogspot Zero AS Link Farm
    elseif ($domain -like "*.blogspot.com*" -and $ascore -eq 0) {
        $isSpam = $true
        $spamReason = "零权重批量 Blogspot 垃圾农场 (如 $domain)"
    }
    # Rule 6: General Zero AS Low-Quality Farm
    elseif ($ascore -eq 0 -and $extLinks -gt 30) {
        $isSpam = $true
        $spamReason = "AS=0 且出站链接高达 $extLinks 条的死链农场"
    }

    if ($isSpam) {
        $spamList += [PSCustomObject]@{
            '域名' = $domain
            '页面权威度(AS)' = $ascore
            '出站链接数' = $extLinks
            '垃圾识别原因' = $spamReason
            '来源页面标题' = $sourceTitle
            '来源页面URL' = $sourceUrl
            '锚文本' = $anchor
        }
    }
    else {
        # Categorize valid links
        $category = ""
        $priority = ""
        $actionPlan = ""

        if ($domain -like "*blog.naver.com*" -or $domain -like "*wordpress.com*" -or $domain -like "*blogspot.com*" -or $domain -like "*medium.com*" -or $sourceUrl -like "*/blog/*" -or $sourceTitle -like "*blog*") {
            $category = "1. 博客与玩家测评 (Blog & Reviews)"
            $priority = "P0 (核心优先)"
            $actionPlan = "真实博客/玩家测评！在评论区发帖或联系作者要求测评你的游戏。"
        }
        elseif ($domain -like "*reddit.com*" -or $domain -like "*github.com*" -or $domain -like "*github.io*" -or $domain -like "*fandom.com*" -or $domain -like "*quora.com*" -or $domain -like "*discord*" -or $domain -like "*steamcommunity.com*" -or $sourceTitle -like "*forum*" -or $sourceTitle -like "*wiki*") {
            $category = "3. 论坛与社区 (Forums & Communities)"
            $priority = "P0 (核心优先)"
            $actionPlan = "高权重社区！创建品牌/游戏展示页，在 Wiki 或帖子回复中嵌入游戏链接。"
        }
        elseif ($domain -like "*itch.io*" -or $domain -like "*gamejolt.com*" -or $domain -like "*poki.com*" -or $domain -like "*crazygames.com*" -or $sourceUrl -like "*unblocked*" -or $sourceTitle -like "*unblocked*" -or $sourceTitle -like "*directory*") {
            $category = "2. 导航和资源目录 (Directories & Catalogs)"
            $priority = "P0 (核心优先)"
            $actionPlan = "游戏目录与 Unblocked 导航站！提交你的 /unblocked.html 专属页入驻。"
        }
        else {
            if ($ascore -ge 15) {
                $category = "4. 客座投稿与媒体软文 (Guest Posts & Media)"
                $priority = "P1 (推荐跟进)"
                $actionPlan = "游戏/科技媒体！联系 Contact Us 发送产品新闻稿或通关指南投稿。"
            } else {
                $category = "4. 客座投稿与媒体软文 (Guest Posts & Media)"
                $priority = "P2 (长尾观察)"
                $actionPlan = "小型独立软文/泛娱乐站点，完成 P0/P1 后有精力再尝试合作。"
            }
        }

        $validList += [PSCustomObject]@{
            '域名' = $domain
            '页面权威度(AS)' = $ascore
            '外链分类大类' = $category
            '推荐优先级' = $priority
            '来源页面标题' = $sourceTitle
            '来源页面URL' = $sourceUrl
            '竞品目标URL' = $targetUrl
            '锚文本' = $anchor
            '是否Nofollow' = $isNofollow
            '实操抄作业指南' = $actionPlan
        }
    }
}

# Sort valid list by priority then AS
$validSorted = $validList | Sort-Object @{Expression='推荐优先级'; Ascending=$true}, @{Expression='页面权威度(AS)'; Descending=$true}
$spamSorted  = $spamList  | Sort-Object @{Expression='页面权威度(AS)'; Descending=$true}

# Export CSVs with BOM
$validSorted | Export-Csv -Path $validCsv -NoTypeInformation -Encoding UTF8
$spamSorted  | Export-Csv -Path $spamCsv  -NoTypeInformation -Encoding UTF8

Write-Host "Valid links count: $($validSorted.Count)"
Write-Host "Cleaned spam links count: $($spamSorted.Count)"

# Generate Excel with 2 Worksheets via COM
try {
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.DisplayAlerts = $false

    if (Test-Path $outputXlsx) { Remove-Item $outputXlsx -Force -ErrorAction SilentlyContinue }

    $wb = $excel.Workbooks.Add()
    
    # Sheet 1: Valid
    $ws1 = $wb.Worksheets.Item(1)
    $ws1.Name = "精选有效外链 (可抄作业)"

    # Import Valid CSV into Sheet 1
    $wbValid = $excel.Workbooks.Open($validCsv)
    $wbValid.Worksheets.Item(1).UsedRange.Copy($ws1.Range("A1"))
    $wbValid.Close($false)

    # Sheet 2: Spam Log
    $ws2 = $wb.Worksheets.Add([System.Reflection.Missing]::Value, $ws1)
    $ws2.Name = "已清洗的垃圾外链 (已过滤)"
    
    $wbSpam = $excel.Workbooks.Open($spamCsv)
    $wbSpam.Worksheets.Item(1).UsedRange.Copy($ws2.Range("A1"))
    $wbSpam.Close($false)

    # Save final XLSX
    $wb.SaveAs($outputXlsx, 51)
    $wb.Close($false)
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null

    Write-Host "SUCCESS: Exported multi-sheet Excel file at $outputXlsx"
}
catch {
    Write-Host "Warning: Excel COM multi-sheet export error: $_"
}
