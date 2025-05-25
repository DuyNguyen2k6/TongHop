# --- Auto-elevate: Support for "irm ... | iex" and physical file ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    if ($MyInvocation.MyCommand.Path) {
        # Trường hợp chạy từ file .ps1 vật lý
        $scriptPath = $MyInvocation.MyCommand.Path
        $wtPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe"
        if (Test-Path $wtPath) {
            Start-Process -FilePath $wtPath -ArgumentList "powershell -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
        } else {
            Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
        }
    } else {
        # Trường hợp chạy bằng irm ... | iex (không có file vật lý)
        $code = $MyInvocation.MyCommand.ScriptBlock.ToString()
        $temp = [IO.Path]::GetTempFileName() -replace '.tmp$', '.ps1'
        Set-Content -Path $temp -Value $code -Encoding UTF8
        $wtPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe"
        if (Test-Path $wtPath) {
            Start-Process -FilePath $wtPath -ArgumentList "powershell -NoProfile -ExecutionPolicy Bypass -File `"$temp`"" -Verb RunAs
        } else {
            Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$temp`"" -Verb RunAs
        }
    }
    exit
}
function Show-Menu {
    Clear-Host
    Write-Host "--------------------------------------------------------------------------"-ForegroundColor Cyan
    Write-Host "========= WINDOWS TOOLKIT MENU ==========" -ForegroundColor Cyan
    Write-Host "--------------------------------------------------------------------------"-ForegroundColor Cyan
    Write-Host "1. System Information"        -ForegroundColor Green
    Write-Host "2. Defender Control"          -ForegroundColor Yellow
    Write-Host "3. Windows Tool (All-in-one)" -ForegroundColor Blue
    Write-Host "4. Driver Backup"             -ForegroundColor Magenta
    Write-Host "5. DNS Changer"               -ForegroundColor Cyan
    Write-Host "6. Shutdown Timer"            -ForegroundColor Red
    Write-Host "7. Exit"                      -ForegroundColor Gray
    Write-Host ""
}

while ($true) {
    Show-Menu
    $choice = Read-Host "Select an option (1-7)"
    switch ($choice) {
        "1" { Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -Command `"irm 'https://raw.githubusercontent.com/DuyNguyen2k6/Tool/main/SystemInfo.ps1' | iex`"" }
        "2" { Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -Command `"irm 'https://raw.githubusercontent.com/DuyNguyen2k6/Tool/main/DefenderControl.ps1' | iex`"" }
        "3" { Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -Command `"irm 'https://raw.githubusercontent.com/DuyNguyen2k6/Tool/main/Wintool.ps1' | iex`"" }
        "4" { Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -Command `"irm 'https://raw.githubusercontent.com/DuyNguyen2k6/Tool/main/Driver.Backup.ps1' | iex`"" }
        "5" { Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -Command `"irm 'https://raw.githubusercontent.com/DuyNguyen2k6/Tool/main/DNS%20Changer.ps1' | iex`"" }
        "6" { Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -Command `"irm 'https://raw.githubusercontent.com/DuyNguyen2k6/Tool/main/shutdown_timer.ps1' | iex`"" }
        "7" { Write-Host "Exiting..."; break }
        default { Write-Host "Invalid choice. Please select 1-7." -ForegroundColor Red }
    }
    if ($choice -ne "7") {
        Write-Host ""
        Write-Host "Press Enter to return to the main menu..." -ForegroundColor Gray
        [void][System.Console]::ReadLine()
    }
}
