if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    if ($MyInvocation.MyCommand.Path) {
        $scriptPath = $MyInvocation.MyCommand.Path

        # Kiểm tra Windows Terminal
        $terminalPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe"

        if (Test-Path $terminalPath) {
            Start-Process -FilePath $terminalPath -ArgumentList "powershell -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
        }
        else {
            Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
        }
    }
    else {
        # Chạy trực tiếp khi dùng irm | iex
        $scriptContent = Invoke-RestMethod "https://raw.githubusercontent.com/DuyNguyen2k6/Tool/main/shutdown_timer.ps1"
        $tempFile = "$env:TEMP\shutdown_timer.ps1"
        $scriptContent | Out-File -FilePath $tempFile -Encoding utf8

        # Kiểm tra Windows Terminal
        $terminalPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe"

        if (Test-Path $terminalPath) {
            Start-Process -FilePath $terminalPath -ArgumentList "powershell -NoProfile -ExecutionPolicy Bypass -File `"$tempFile`"" -Verb RunAs
        }
        else {
            Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempFile`"" -Verb RunAs
        }
    }

    exit
}

# Yêu cầu quyền admin và mở lại trong Windows Terminal nếu có
if (-not ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    $scriptPath = $MyInvocation.MyCommand.Definition

    if (Get-Command wt.exe -ErrorAction SilentlyContinue) {
        Start-Process wt.exe "-w 0 nt -p `"Windows PowerShell`" powershell -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    } else {
        Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    }
    exit
}

# Căn chỉnh kích thước cửa sổ (80 cột x 25 dòng)
try {
    $host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(80, 25)
    $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(80, 300)
} catch {
    # Bỏ qua nếu không thể thay đổi (ví dụ trong Windows Terminal)
}

function Show-Menu {
    Clear-Host
    Write-Host "===============================" -ForegroundColor Magenta
    Write-Host "      POWER SCHEDULER TOOL     " -ForegroundColor Yellow
    Write-Host "===============================" -ForegroundColor Magenta
    Write-Host "1. Shutdown" -ForegroundColor Red
    Write-Host "2. Restart" -ForegroundColor Cyan
    Write-Host "3. Sleep" -ForegroundColor Green
    Write-Host "4. Cancel scheduled action" -ForegroundColor DarkYellow
    Write-Host "0. Exit" -ForegroundColor Gray
}

function Schedule-Action {
    param (
        [string]$action,
        [int]$minutes
    )

    $seconds = $minutes * 60
    Write-Host ""
    Write-Host "$action scheduled after $minutes minute(s)." -ForegroundColor Cyan
    Write-Host "Press 'Q' then Enter at any time to cancel." -ForegroundColor Yellow

    for ($i = $seconds; $i -ge 0; $i--) {
        $time = [TimeSpan]::FromSeconds($i).ToString("hh\:mm\:ss")
        Write-Host "`rTime left: $time   " -NoNewline

        if ([console]::KeyAvailable) {
            $key = [console]::ReadKey($true)
            if ($key.KeyChar -eq 'q' -or $key.KeyChar -eq 'Q') {
                Write-Host "`nCancelled by user." -ForegroundColor Green
                return
            }
        }

        Start-Sleep -Milliseconds 950
    }

    switch ($action) {
        "shutdown" { shutdown /s /f /t 0 }
        "restart"  { shutdown /r /f /t 0 }
        "sleep"    { rundll32.exe powrprof.dll,SetSuspendState 0,1,0 }
    }
}

do {
    Show-Menu
    $choice = Read-Host "`nSelect an option (0-4)"

    switch ($choice) {
        "1" {
            $min = Read-Host "Shutdown after how many minutes?"
            Schedule-Action -action "shutdown" -minutes $min
        }
        "2" {
            $min = Read-Host "Restart after how many minutes?"
            Schedule-Action -action "restart" -minutes $min
        }
        "3" {
            $min = Read-Host "Sleep after how many minutes?"
            Schedule-Action -action "sleep" -minutes $min
        }
        "4" {
            shutdown /a
            Write-Host "Cancelled any scheduled shutdown/restart." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
        "0" {
            Write-Host "Goodbye!" -ForegroundColor Gray
        }
        default {
            Write-Host "Invalid option." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }

    if ($choice -ne "0") {
        Write-Host "`nPress Enter to return to menu..."
        [void][System.Console]::ReadLine()
    }

} while ($choice -ne "0")
Write-Host ""
Write-Host "Press Enter to return to the main menu..." -ForegroundColor Gray
[void][System.Console]::ReadLine()
