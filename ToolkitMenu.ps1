function Show-Menu {
    Clear-Host
    Write-Host "========= WINDOWS TOOLKIT MENU ==========" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. System Information"      -ForegroundColor Green
    Write-Host "2. Defender Control"        -ForegroundColor Yellow
    Write-Host "3. Windows Tool (All-in-one)" -ForegroundColor Blue
    Write-Host "4. Driver Backup"           -ForegroundColor Magenta
    Write-Host "5. DNS Changer"             -ForegroundColor Cyan
    Write-Host "6. Shutdown Timer"          -ForegroundColor Red
    Write-Host "7. Exit"                    -ForegroundColor Gray
    Write-Host ""
}

while ($true) {
    Show-Menu
    $choice = Read-Host "Select an option (1-7)"
    switch ($choice) {
        "1" { powershell -NoProfile -ExecutionPolicy Bypass -File ".\SystemInfo.ps1" }
        "2" { powershell -NoProfile -ExecutionPolicy Bypass -File ".\DefenderControl.ps1" }
        "3" { powershell -NoProfile -ExecutionPolicy Bypass -File ".\Wintool.ps1" }
        "4" { powershell -NoProfile -ExecutionPolicy Bypass -File ".\Driver.Backup.ps1" }
        "5" { powershell -NoProfile -ExecutionPolicy Bypass -File ".\DNS Changer.ps1" }
        "6" { powershell -NoProfile -ExecutionPolicy Bypass -File ".\shutdown_timer.ps1" }
        "7" { Write-Host "Exiting..."; break }
        default { Write-Host "Invalid choice. Please select 1-7." -ForegroundColor Red }
    }
}
