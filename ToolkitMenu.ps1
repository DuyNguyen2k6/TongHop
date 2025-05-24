# Windows Toolkit CLI - Colored Menu + Clean Titles + Return on Exit

function Show-Menu {
    
    Clear-Host
    Write-Host "=== WINDOWS TOOLKIT MENU ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Wintool (All-in-one)" -ForegroundColor Yellow
    Write-Host "2. Driver Backup Tool"   -ForegroundColor Green
    Write-Host "3. DNS Changer Tool"     -ForegroundColor Magenta
    Write-Host "4. Shutdown Timer Tool"  -ForegroundColor Blue
    Write-Host "0. Exit"                 -ForegroundColor Red  
    Write ----------------------------
    Write --------DuyNguyen2k6--------
    Write ----------------------------
}

function Wait-For-Next {
    while ($true) {
        $next = Read-Host "`nPress [E] to return to menu, [M] to exit"
        switch ($next.ToUpper()) {
            "E" { return }
            "M" { exit }
            Default { Write-Host "Invalid input. Please press E or M." -ForegroundColor Red }
        }
    }
}

function Confirm-And-RunInline {
    param (
        [string]$name,
        [string]$url
    )
    Write-Host ""
    $confirm = Read-Host "Are you sure you want to run '$name'? (y/n)"
    if ($confirm -eq "y") {
        Write-Host "Downloading and executing $name..." -ForegroundColor Yellow
        try {
            irm $url | iex
        } catch {
            Write-Host "Error while downloading the script: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Action cancelled." -ForegroundColor DarkGray
    }
    Wait-For-Next
}

function Run-InNewShell {
    param (
        [string]$name,
        [string]$url
    )
    Write-Host ""
    $confirm = Read-Host "Are you sure you want to run '$name'? (y/n)"
    if ($confirm -eq "y") {
        $script = "irm '$url' | iex"
        Write-Host "Opening a new PowerShell window for $name..." -ForegroundColor Yellow
        Start-Process powershell.exe -ArgumentList "-NoExit", "-NoLogo", "-Command $script"
        Write-Host "`nPress any key to return to menu after closing the tool window..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } else {
        Write-Host "Action cancelled." -ForegroundColor DarkGray
    }
}

do {
    Show-Menu
    $choice = Read-Host "`nEnter your choice (0-4)"

    switch ($choice) {
        "1" { Confirm-And-RunInline "Wintool.ps1" "https://raw.githubusercontent.com/DuyNguyen2k6/Tool/main/Wintool.ps1" }
        "2" { Confirm-And-RunInline "Driver.Backup.ps1" "https://raw.githubusercontent.com/DuyNguyen2k6/Tool/main/Driver.Backup.ps1" }
        "3" { Run-InNewShell "DNS Changer.ps1" "https://raw.githubusercontent.com/DuyNguyen2k6/Tool/main/DNS%20Changer.ps1" }
        "4" { Run-InNewShell "Shutdown Timer.ps1" "https://raw.githubusercontent.com/DuyNguyen2k6/Tool/main/shutdown_timer.ps1" }
        "0" { Write-Host "Goodbye!" -ForegroundColor Green; break }
        Default { Write-Host "Invalid choice!" -ForegroundColor Red; Pause }
    }
} while ($true)
