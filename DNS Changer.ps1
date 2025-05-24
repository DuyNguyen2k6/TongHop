# =============================
# DNS Changer Tool (Auto Admin)
# =============================

# Link raw script của bạn trên GitHub
$rawLink = 'https://raw.githubusercontent.com/DuyNguyen2k6/Tool/main/DNS%20Changer.ps1'

function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    try {
        $tempFile = "$env:TEMP\DNSChanger_temp.ps1"
        Invoke-WebRequest -Uri $rawLink -OutFile $tempFile
        Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$tempFile`"" -Verb RunAs
        exit
    } catch {
        Write-Host "Không thể tải script về máy. Vui lòng thử lại hoặc kiểm tra kết nối mạng." -ForegroundColor Red
        exit
    }
}

# ======= CODE ĐỔI DNS =========

# Danh sách DNS phổ biến
$dnsList = @(
    @{ Name = "Google";     Primary = "8.8.8.8";      Secondary = "8.8.4.4"      },
    @{ Name = "Control D";  Primary = "76.76.2.0";    Secondary = "76.76.10.0"   },
    @{ Name = "Quad9";      Primary = "9.9.9.9";      Secondary = "149.112.112.112" },
    @{ Name = "Cloudflare"; Primary = "1.1.1.1";      Secondary = "1.0.0.1"      },
    @{ Name = "OpenDNS";    Primary = "208.67.222.222"; Secondary = "208.67.220.220" }
)

function Get-ActiveAdapters {
    # Lấy các adapter mạng vật lý đang UP và có IPv4
    Get-NetAdapter -Physical | Where-Object { $_.Status -eq "Up" } | ForEach-Object {
        $ip = (Get-NetIPAddress -InterfaceIndex $_.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue)
        if ($ip) { $_ }
    }
}

function Show-CurrentDNS {
    $adapters = Get-ActiveAdapters
    if (!$adapters) {
        Write-Host "Không tìm thấy adapter mạng nào đang hoạt động!" -ForegroundColor Red
        return
    }
    Write-Host "`n=== DANH SÁCH ADAPTER MẠNG ĐANG HOẠT ĐỘNG ===" -ForegroundColor Cyan
    $adapters | ForEach-Object { Write-Host "$($_.ifIndex): $($_.Name)" }
    $adapterIndex = Read-Host "`nNhập ifIndex của adapter muốn kiểm tra DNS"
    $adapter = $adapters | Where-Object { $_.ifIndex -eq [int]$adapterIndex }
    if ($adapter) {
        $dnsServers = (Get-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4).ServerAddresses
        Write-Host "DNS hiện tại của $($adapter.Name): $($dnsServers -join ', ')" -ForegroundColor Green
    } else {
        Write-Host "Không tìm thấy adapter có ifIndex này!" -ForegroundColor Red
    }
}

function Change-DNS {
    $adapters = Get-ActiveAdapters
    if (!$adapters) {
        Write-Host "Không tìm thấy adapter mạng nào đang hoạt động!" -ForegroundColor Red
        return
    }
    Write-Host "`n=== DANH SÁCH ADAPTER MẠNG ĐANG HOẠT ĐỘNG ===" -ForegroundColor Cyan
    $adapters | ForEach-Object { Write-Host "$($_.ifIndex): $($_.Name)" }
    $adapterIndex = Read-Host "`nNhập ifIndex của adapter muốn đổi DNS"
    $adapter = $adapters | Where-Object { $_.ifIndex -eq [int]$adapterIndex }
    if (-not $adapter) {
        Write-Host "Không tìm thấy adapter có ifIndex này!" -ForegroundColor Red
        return
    }

    Write-Host "`n=== CHỌN DNS MUỐN ĐỔI ===" -ForegroundColor Cyan
    for ($i = 0; $i -lt $dnsList.Count; $i++) {
        Write-Host "$($i + 1). $($dnsList[$i].Name) ($($dnsList[$i].Primary), $($dnsList[$i].Secondary))"
    }
    $dnsChoice = Read-Host "Nhập số tương ứng DNS muốn sử dụng"
    if ($dnsChoice -match '^\d+$' -and $dnsChoice -ge 1 -and $dnsChoice -le $dnsList.Count) {
        $selectedDNS = $dnsList[$dnsChoice - 1]
        Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses @($selectedDNS.Primary, $selectedDNS.Secondary)
        Write-Host "Đã đổi DNS cho $($adapter.Name) thành: $($selectedDNS.Primary), $($selectedDNS.Secondary)" -ForegroundColor Green
    } else {
        Write-Host "Lựa chọn không hợp lệ!" -ForegroundColor Red
    }
}

# ========== MENU ==========
do {
    Write-Host "`n========= DNS Changer ========="
    Write-Host "1. Xem DNS hiện tại"
    Write-Host "2. Đổi DNS"
    Write-Host "0. Thoát"
    $choice = Read-Host "Chọn chức năng (1/2/0)"
    switch ($choice) {
        "1" { Show-CurrentDNS }
        "2" { Change-DNS }
        "0" { Write-Host "Kết thúc chương trình." -ForegroundColor Yellow }
        default { Write-Host "Chức năng không hợp lệ!" -ForegroundColor Red }
    }
} while ($choice -ne "0")
