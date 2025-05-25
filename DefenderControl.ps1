


function Show-Status {
    $realTime = (Get-MpPreference).DisableRealtimeMonitoring
    $tamper = (Get-CimInstance -Namespace "root\Microsoft\Windows\Defender" -ClassName MSFT_MpComputerStatus).IsTamperProtected

    Write-Host "`n===== Defender Status =====" -ForegroundColor Cyan
    Write-Host "Real-time Protection: " -NoNewline
    if ($realTime) {
        Write-Host "OFF" -ForegroundColor Red
    } else {
        Write-Host "ON" -ForegroundColor Green
    }

    Write-Host "Tamper Protection:     " -NoNewline
    if ($tamper) {
        Write-Host "ON (cannot change via script)" -ForegroundColor Yellow
    } else {
        Write-Host "OFF" -ForegroundColor Gray
    }
    Write-Host ""
}

function Show-Menu {
    Clear-Host
    Write-Host "=== Windows Defender Control Tool ===" -ForegroundColor Cyan
    Write-Host "1. Disable Real-time Protection"
    Write-Host "2. Enable Real-time Protection"
    Write-Host "3. Completely Disable Defender (Registry)"
    Write-Host "4. Enable Defender"
    Write-Host "0. Exit"
}

do {
    Show-Menu
    $choice = Read-Host "`nEnter your choice"
    switch ($choice) {
        "1" {
            Write-Host ">> Disabling Real-time Protection..." -ForegroundColor Yellow
            Set-MpPreference -DisableRealtimeMonitoring $true
            Show-Status
        }
        "2" {
            Write-Host ">> Enabling Real-time Protection..." -ForegroundColor Green
            Set-MpPreference -DisableRealtimeMonitoring $false
            Show-Status
        }
        "3" {
            Write-Host ">> Disabling Windows Defender completely..." -ForegroundColor Red
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 1 -Force
            Write-Host ">> Please restart your computer to apply changes." -ForegroundColor DarkYellow
            Show-Status
        }
        "4" {
            Write-Host ">> Enabling Windows Defender..." -ForegroundColor Green
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -ErrorAction SilentlyContinue
            Write-Host ">> Please restart your computer to apply changes." -ForegroundColor DarkYellow
            Show-Status
        }
    }
    if ($choice -ne "0") {
        Write-Host "`nPress Enter to return to the menu..." -ForegroundColor DarkGray
        Read-Host
    }
} while ($choice -ne "0")

Write-Host ">> Exiting program." -ForegroundColor Gray
Write-Host ""
Write-Host "Press Enter to return to the main menu..." -ForegroundColor Gray
[void][System.Console]::ReadLine()

