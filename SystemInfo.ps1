Clear-Host
Write-Host "=== SYSTEM INFORMATION REPORT ===" -ForegroundColor Cyan

# OS & User
$os = Get-CimInstance Win32_OperatingSystem
Write-Host "`n=== OS / USER INFO ===" -ForegroundColor Yellow
Write-Host "OS: $($os.Caption) $($os.Version) ($($os.OSArchitecture))"
Write-Host "Computer Name: $($os.CSName)"
Write-Host "User: $env:USERNAME"

# System Model
$sys = Get-CimInstance Win32_ComputerSystem
Write-Host "System Model: $($sys.Model)"

# Windows Activation Info 
Write-Host "`n=== WINDOWS ACTIVATION ===" -ForegroundColor Green

try {
    $lic = Get-CimInstance -Query "SELECT PartialProductKey, LicenseStatus FROM SoftwareLicensingProduct WHERE LicenseStatus = 1 AND PartialProductKey IS NOT NULL" -ErrorAction Stop
    if ($lic) {
        Write-Host "Windows Activation: Activated (Key: ****-$($lic.PartialProductKey))"
    } else {
        Write-Host "Windows Activation: Not activated"
    }
} catch {
    Write-Host "Activation check failed: $($_.Exception.Message)"
}



# Boot Time
$bootRaw = $os.LastBootUpTime
Write-Host "`n=== BOOT TIME ===" -ForegroundColor Magenta
if ($bootRaw -and $bootRaw -match '^\d{14}\.\d{6}\+\d{3}$') {
    try {
        $bootTime = [Management.ManagementDateTimeConverter]::ToDateTime($bootRaw)
        Write-Host "Boot Time: $bootTime"
    } catch {
        Write-Host "Boot Time: Invalid format"
    }
} else {
    Write-Host "Boot Time: N/A"
}

# CPU
$cpu = Get-CimInstance Win32_Processor
Write-Host "`n=== CPU INFO ===" -ForegroundColor Cyan
Write-Host "Processor: $($cpu.Name)"
Write-Host "Cores: $($cpu.NumberOfCores)"
Write-Host "Logical Processors: $($cpu.NumberOfLogicalProcessors)"

# GPU
Write-Host "`n=== GPU INFO ===" -ForegroundColor Blue
Get-CimInstance Win32_VideoController | ForEach-Object {
    Write-Host "$($_.Name)"
}

# RAM
$ram = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$freeRam = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
Write-Host "`n=== RAM INFO ===" -ForegroundColor DarkYellow
Write-Host "Total: $ram GB"
Write-Host "Free: $freeRam GB"

# Disk
Write-Host "`n=== DISK INFO ===" -ForegroundColor DarkCyan
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $size = [math]::Round($_.Size / 1GB, 2)
    $free = [math]::Round($_.FreeSpace / 1GB, 2)
    Write-Host "$($_.DeviceID) - $($_.VolumeName): $free GB free / $size GB total"
}

# Network
Write-Host "`n=== NETWORK ADAPTERS ===" -ForegroundColor DarkGreen
Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | ForEach-Object {
    Write-Host "$($_.Name): $($_.InterfaceDescription) - $($_.LinkSpeed)"
}

Write-Host "`n=== IP CONFIGURATION ===" -ForegroundColor DarkMagenta
Get-NetIPConfiguration | ForEach-Object {
    Write-Host "$($_.InterfaceAlias): IP = $($_.IPv4Address.IPAddress), Gateway = $($_.IPv4DefaultGateway.NextHop)"
}

# Mainboard & BIOS
Write-Host "`n=== MOTHERBOARD INFO ===" -ForegroundColor Red
$baseboard = Get-CimInstance Win32_BaseBoard
Write-Host "Manufacturer: $($baseboard.Manufacturer)"
Write-Host "Model: $($baseboard.Product)"

$bios = Get-CimInstance Win32_BIOS
Write-Host "`nBIOS Version: $($bios.SMBIOSBIOSVersion)"
Write-Host "BIOS Vendor: $($bios.Manufacturer)"

Write-Host "`n=== DONE ===" -ForegroundColor Cyan

# Giữ cửa sổ mở khi chạy bằng chuột phải
if ($Host.Name -eq "ConsoleHost") {
    Write-Host "`nScript completed. Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
Write-Host ""
Write-Host "Press Enter to return to the main menu..." -ForegroundColor Gray
[void][System.Console]::ReadLine()
