# PowerShell Cross-Validation Script for Competitor Backlinks (Windyan / Gofei Methodology)

$files = @(
    @{ Name = "pokerogue.cc"; Path = "C:\Users\69444\Downloads\pokerogue.cc-backlinks.csv" },
    @{ Name = "sprunkigame.io"; Path = "C:\Users\69444\Downloads\sprunkigame.io-backlinks.csv" },
    @{ Name = "sprunkid.com"; Path = "C:\Users\69444\Downloads\sprunkid.com-backlinks.csv" }
)

$outputCsv  = 'f:\旅行携带资料\Games\slimekeyboardescape\cross_validated_backlinks.csv'
$outputXlsx = 'f:\旅行携带资料\Games\slimekeyboardescape\cross_validated_backlinks.xlsx'

$domainMap = @{}

foreach ($f in $files) {
    $compName = $f.Name
    $csvPath  = $f.Path

    if (-not (Test-Path $csvPath)) {
        Write-Host "Warning: $csvPath not found!"
        continue
    }

    $rows = Import-Csv -Path $csvPath -Encoding UTF8

    foreach ($r in $rows) {
        $ascore     = [int]($r.'Page ascore')
        $sourceTitle = [string]($r.'Source title')
        $sourceUrl   = [string]($r.'Source url')
        $anchor      = [string]($r.'Anchor')
        $extLinks    = [int]($r.'External links')
        $isNofollow  = [string]($r.'Nofollow')

        $refDomain = ""
        if ($sourceUrl -match "https?://([^/]+)") {
            $refDomain = $matches[1]
        }

        if ([string]::IsNullOrWhiteSpace($refDomain)) { continue }

        # Filter out obvious spam / SERP caches / Telegram ads
        if ($refDomain -like "*search.yahoo.com*" -or $refDomain -like "*google.com*" -or $refDomain -like "*bing.com*") { continue }
        if ($anchor -like "*TG @*" -or $anchor -like "*TELEGRAM*" -or $sourceTitle -like "*TG @*" -or $refDomain -like "*seol.store*") { continue }
        if ($extLinks -gt 500 -and $ascore -lt 5) { continue }
        if ($refDomain -like "*.alpinelinux.org*" -or $refDomain -like "*.eden-court.co.uk*" -or $refDomain -like "*.readingrights.org*") { continue }

        if (-not $domainMap.ContainsKey($refDomain)) {
            $domainMap[$refDomain] = @{
                Domain        = $refDomain
                MaxAS         = $ascore
                Competitors   = [System.Collections.Generic.HashSet[string]]::new()
                SampleTitles  = [System.Collections.Generic.HashSet[string]]::new()
                SampleURLs    = [System.Collections.Generic.HashSet[string]]::new()
                Anchors       = [System.Collections.Generic.HashSet[string]]::new()
            }
        }

        $entry = $domainMap[$refDomain]
        if ($ascore -gt $entry.MaxAS) { $entry.MaxAS = $ascore }
        [void]$entry.Competitors.Add($compName)
        if (-not [string]::IsNullOrWhiteSpace($sourceTitle)) { [void]$entry.SampleTitles.Add($sourceTitle) }
        if (-not [string]::IsNullOrWhiteSpace($sourceUrl)) { [void]$entry.SampleURLs.Add($sourceUrl) }
        if (-not [string]::IsNullOrWhiteSpace($anchor)) { [void]$entry.Anchors.Add($anchor) }
    }
}

$results = @()

foreach ($kv in $domainMap.GetEnumerator()) {
    $item = $kv.Value
    $overlapCount = $item.Competitors.Count
    $compListStr  = ($item.Competitors | Sort-Object) -join ", "
    $sampleUrl    = ($item.SampleURLs | Select-Object -First 1)
    $sampleTitle  = ($item.SampleTitles | Select-Object -First 1)

    $refDomain = $item.Domain
    $ascore    = $item.MaxAS

    $category = ""
    $priority = ""
    $actionPlan = ""

    # Star rating for overlap
    $starRating = ""
    if ($overlapCount -ge 3) {
        $starRating = "⭐⭐⭐ 重合度高 (多同行通用)"
        $priority = "P0 (必做金矿)"
    } elseif ($overlapCount -eq 2) {
        $starRating = "⭐⭐ 重合度中 (2家同行验证)"
        $priority = "P0 (高价值)"
    } else {
        $starRating = "⭐ 独立覆盖 (单同行踩点)"
        if ($ascore -ge 20) { $priority = "P1 (推荐跟进)" }
        else { $priority = "P2 (备选长尾)" }
    }

    # Categorization logic
    if ($refDomain -like "*blog.naver.com*" -or $refDomain -like "*wordpress.com*" -or $refDomain -like "*blogspot.com*" -or $refDomain -like "*medium.com*" -or $sampleUrl -like "*/blog/*" -or $sampleTitle -like "*blog*") {
        $category = "1. 博客与玩家测评 (Blog & Reviews)"
        $actionPlan = "博客与玩家测评！评论区带链接或发 OutReach 邮件申请测评。"
    }
    elseif ($refDomain -like "*reddit.com*" -or $refDomain -like "*github.com*" -or $refDomain -like "*github.io*" -or $refDomain -like "*fandom.com*" -or $refDomain -like "*quora.com*" -or $refDomain -like "*discord*" -or $refDomain -like "*steamcommunity.com*" -or $sampleTitle -like "*forum*" -or $sampleTitle -like "*wiki*") {
        $category = "3. 论坛与社区 (Forums & Communities)"
        $actionPlan = "高权重 UGC 社区！创建品牌/游戏展示页或在 Wiki/论坛回复中嵌入链接。"
    }
    elseif ($refDomain -like "*itch.io*" -or $refDomain -like "*gamejolt.com*" -or $refDomain -like "*poki.com*" -or $refDomain -like "*crazygames.com*" -or $sampleUrl -like "*unblocked*" -or $sampleTitle -like "*unblocked*" -or $sampleTitle -like "*directory*") {
        $category = "2. 导航和资源目录 (Directories & Catalogs)"
        $actionPlan = "游戏目录与学校 Unblocked 导航站！提交 /unblocked.html 专属页入驻。"
    }
    else {
        $category = "4. 客座投稿与媒体软文 (Guest Posts & Media)"
        $actionPlan = "科技/游戏媒体站！联系 Contact Us 发送新闻稿或跑酷攻略投稿。"
    }

    $results += [PSCustomObject]@{
        '交叉重合度' = $starRating
        '重合站点数量' = $overlapCount
        '使用该外链的竞品' = $compListStr
        '引荐域名' = $refDomain
        '域名权威度(AS)' = $ascore
        '外链分类' = $category
        '推荐优先级' = $priority
        '代表性来源页面' = $sampleUrl
        '代表性页面标题' = $sampleTitle
        '实操抄作业指南' = $actionPlan
    }
}

# Sort by Overlap Count Descending, then AS Descending
$sortedResults = $results | Sort-Object @{Expression='重合站点数量'; Descending=$true}, @{Expression='域名权威度(AS)'; Descending=$true}

# Export CSV with BOM
$sortedResults | Export-Csv -Path $outputCsv -NoTypeInformation -Encoding UTF8

Write-Host "Cross-validation complete. Unique valid domains: $($sortedResults.Count)"

# Generate XLSX via COM
try {
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.DisplayAlerts = $false

    if (Test-Path $outputXlsx) { Remove-Item $outputXlsx -Force -ErrorAction SilentlyContinue }

    $wb = $excel.Workbooks.Open($outputCsv)
    $wb.SaveAs($outputXlsx, 51)
    $wb.Close($false)
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null

    Write-Host "SUCCESS: Generated cross-validated XLSX file at $outputXlsx"
} catch {
    Write-Host "Excel COM conversion warning: $_"
}
