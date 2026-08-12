# PowerShell script to categorize Pokerogue backlinks for Slime Keyboard Escape
$inputCsv = 'C:\Users\69444\Downloads\pokerogue.cc-backlinks.csv'
$outputCsv = 'f:\旅行携带资料\Games\slimekeyboardescape\classified_backlinks.csv'
$outputXlsx = 'f:\旅行携带资料\Games\slimekeyboardescape\classified_backlinks.xlsx'

if (-not (Test-Path $inputCsv)) {
    Write-Error "Input CSV not found at $inputCsv"
    exit 1
}

$data = Import-Csv -Path $inputCsv -Encoding UTF8

$results = @()

foreach ($row in $data) {
    $ascore = [int]($row.'Page ascore')
    $sourceTitle = [string]($row.'Source title')
    $sourceUrl = [string]($row.'Source url')
    $targetUrl = [string]($row.'Target url')
    $anchor = [string]($row.'Anchor')
    $isNofollow = [string]($row.'Nofollow')
    
    $domain = ""
    if ($sourceUrl -match "https?://([^/]+)") {
        $domain = $matches[1]
    }

    $category = ""
    $priority = ""
    $actionPlan = ""

    # Rule 1: Search engine SERPs & PBN/Parasite Subdomains
    if ($domain -like "*search.yahoo.com*" -or $domain -like "*google.com*" -or $domain -like "*bing.com*") {
        $category = "5. 搜索引擎缓存 (无需跟进)"
        $priority = "P3 (忽略)"
        $actionPlan = "搜索引擎 SERP 缓存页面，非真实反链，直接忽略。"
    }
    elseif ($domain -like "*.alpinelinux.org*" -or $domain -like "*.eden-court.co.uk*" -or $domain -like "*.readingrights.org*" -or $domain -like "*.existentialcomics.com*") {
        $category = "5. 黑帽/寄生虫泛解析 (高风险)"
        $priority = "P3 (避坑)"
        $actionPlan = "过期高权重域名被挂载的寄生虫页面。白帽站点千万不要模仿买此类链接，容易遭 Google 算法惩罚。"
    }
    # Rule 2: Blogs & Player Reviews
    elseif ($domain -like "*blog.naver.com*" -or $domain -like "*wordpress.com*" -or $domain -like "*blogspot.com*" -or $domain -like "*medium.com*" -or $sourceUrl -like "*/blog/*" -or $sourceTitle -like "*blog*") {
        $category = "1. 博客与玩家测评 (Blog & Reviews)"
        $priority = "P0 (核心优先)"
        $actionPlan = "独立博客/玩家测评！去文章下发表正规评论带网址，或给博客作者发 OutReach 邮件申请测评你的游戏。"
    }
    # Rule 3: Forums & Communities & Wiki
    elseif ($domain -like "*reddit.com*" -or $domain -like "*github.com*" -or $domain -like "*github.io*" -or $domain -like "*fandom.com*" -or $domain -like "*quora.com*" -or $domain -like "*discord*" -or $domain -like "*steamcommunity.com*" -or $sourceTitle -like "*forum*" -or $sourceTitle -like "*wiki*") {
        $category = "3. 论坛与社区 (Forums & Communities)"
        $priority = "P0 (核心优先)"
        $actionPlan = "高权重 UGC 社区！创建品牌/游戏展示页、在 GitHub Pages 或 Fandom 社区建立 Wiki 词条、在 Reddit/论坛发贴。"
    }
    # Rule 4: Directories & Unblocked Lists
    elseif ($domain -like "*itch.io*" -or $domain -like "*gamejolt.com*" -or $domain -like "*poki.com*" -or $domain -like "*crazygames.com*" -or $sourceUrl -like "*unblocked*" -or $sourceTitle -like "*unblocked*" -or $sourceTitle -like "*directory*" -or $sourceTitle -like "*catalog*") {
        $category = "2. 导航和资源目录 (Directories & Catalogs)"
        $priority = "P0 (核心优先)"
        $actionPlan = "游戏目录与学校 Unblocked 导航站！直接免费注册提交你的游戏链接或将 /unblocked.html 专属页提交入驻。"
    }
    # Rule 5: Guest Posts & Media Soft Articles
    else {
        if ($ascore -ge 20) {
            $category = "4. 客座投稿与媒体软文 (Guest Posts & Media)"
            $priority = "P1 (推荐跟进)"
            $actionPlan = "行业/科技/游戏媒体！找到 Contact Us / Editorial 页面邮箱，发送产品新闻稿或申请投稿发布软文。"
        }
        else {
            $category = "4. 客座投稿与媒体软文 (Guest Posts & Media)"
            $priority = "P2 (长尾观察)"
            $actionPlan = "小型独立软文/泛娱乐站点，完成 P0/P1 后有空余精力时再尝试联系合作。"
        }
    }

    $results += [PSCustomObject]@{
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

# Sort by Priority then AS
$resultsSorted = $results | Sort-Object @{Expression='推荐优先级'; Ascending=$true}, @{Expression='页面权威度(AS)'; Descending=$true}

# Export CSV with BOM
$resultsSorted | Export-Csv -Path $outputCsv -NoTypeInformation -Encoding UTF8

# Export XLSX via COM if available
try {
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.DisplayAlerts = $false
    $wb = $excel.Workbooks.Open($outputCsv)
    $wb.SaveAs($outputXlsx, 51)
    $wb.Close($false)
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    Write-Host "XLSX file successfully refreshed at $outputXlsx"
} catch {
    Write-Host "Warning: Could not save XLSX via COM: $_"
}

Write-Host "Processing complete. Total items: $($resultsSorted.Count)"
