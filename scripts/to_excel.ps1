try {
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.DisplayAlerts = $false

    $csvPath = 'f:\旅行携带资料\Games\slimekeyboardescape\classified_backlinks.csv'
    $xlsxPath = 'f:\旅行携带资料\Games\slimekeyboardescape\classified_backlinks.xlsx'

    $wb = $excel.Workbooks.Open($csvPath)
    $wb.SaveAs($xlsxPath, 51) # 51 = xlOpenXMLWorkbook (.xlsx)
    $wb.Close($false)
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    Write-Host "SUCCESS: Generated native XLSX file at $xlsxPath"
} catch {
    Write-Host "Excel COM not available or error: $_"
}
