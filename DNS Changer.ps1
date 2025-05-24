# Script PowerShell: Xem và thay đổi DNS, tự động yêu cầu quyền admin khi cần
# Căn chỉnh kích thước cửa sổ PowerShell vừa đủ để hiển thị nội dung

# Tự động yêu cầu quyền Administrator nếu chưa có
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "powershell.exe"
        $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -Command `"irm 'https://raw.githubusercontent.com/DuyNguyen2k6/Tool/main/DNS%20Changer.ps1' | iex`""
        $psi.Verb = "runas"
        [System.Diagnostics.Process]::Start($psi) | Out-Null
        exit
    } catch {
        Write-Host "Không thể khởi động lại với quyền Administrator: $_" -ForegroundColor Red
        Read-Host -Prompt "Nhấn Enter để thoát..."
        exit
    }
}

# Đặt kích thước cửa sổ PowerShell vừa đủ để hiển thị nội dung
try {
    [Console]::WindowWidth = 70
    [Console]::WindowHeight = 20
    [Console]::BufferWidth = 70
    [Console]::BufferHeight = 100
} catch {
    Write-Host "Lỗi khi đặt kích thước cửa sổ: $_" -ForegroundColor Red
}

try {
    # Danh sách DNS công cộng
    $dnsList = @{
        1 = @{ Name = "Google Public DNS"; IPv4 = "8.8.8.8,8.8.4.4" };
        2 = @{ Name = "Cloudflare DNS"; IPv4 = "1.1.1.1,1.0.0.1" };
        3 = @{ Name = "OpenDNS"; IPv4 = "208.67.222.222,208.67.220.220" };
        4 = @{ Name = "Quad9"; IPv4 = "9.9.9.9,149.112.112.112" };
        5 = @{ Name = "Verisign"; IPv4 = "64.6.64.6,64.6.65.6" };
        6 = @{ Name = "Comodo Secure DNS"; IPv4 = "8.26.56.26,8.20.247.20" };
        7 = @{ Name = "Level3 DNS"; IPv4 = "209.244.0.4,209.244.0.5" };
        8 = @{ Name = "DynDNS"; IPv4 = "216.146.35.35,208.67.222.222" };
        9 = @{ Name = "Hurricane Electric"; IPv4 = "4.2.2.1,4.2.2.2" };
        10 = @{ Name = "DNS.Watch"; IPv4 = "84.200.69.80,84.200.69.81" };
        11 = @{ Name = "Control D"; IPv4 = "76.76.2.0,76.76.10.0" };
        12 = @{ Name = "OpenDNS Home"; IPv4 = "208.67.222.222,208.67.220.220" };
        13 = @{ Name = "CleanBrowsing"; IPv4 = "185.228.168.9,185.228.169.9" };
        14 = @{ Name = "Alternate DNS"; IPv4 = "76.76.19.19,76.223.122.150" };
        15 = @{ Name = "AdGuard DNS"; IPv4 = "94.140.14.14,94.140.15.15" }
    }

    while ($true) {
        Clear-Host
        Write-Host "`n=== QUẢN LÝ DNS ===" -ForegroundColor Green
        Write-Host "1. Hiển thị thông tin DNS"
        Write-Host "2. Thay đổi DNS"
        Write-Host "3. Thoát"
        $choice = Read-Host "`nNhập lựa chọn (1-3)"

        if ($choice -eq "3") {
            Clear-Host
            Write-Host "Đã thoát chương trình." -ForegroundColor Yellow
            break
        }

        # Lấy tất cả các adapter mạng đang hoạt động
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

        if (-not $adapters) {
            Write-Host "Không tìm thấy adapter mạng nào đang hoạt động." -ForegroundColor Red
            Read-Host -Prompt "Nhấn Enter để tiếp tục..."
            continue
        }

        if ($choice -eq "1") {
            # Hiển thị thông tin DNS
            Clear-Host
            Write-Host "`n=== THÔNG TIN CẤU HÌNH DNS ===" -ForegroundColor Green
            foreach ($adapter in $adapters) {
                Write-Host "`nAdapter: $($adapter.Name)" -ForegroundColor Cyan
                Write-Host "----------------------------"
                
                # Lấy thông tin DNS từ adapter
                try {
                    $dnsConfig = Get-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ErrorAction Stop
                } catch {
                    Write-Host "Lỗi khi lấy thông tin DNS: $_" -ForegroundColor Red
                    continue
                }
                
                if ($dnsConfig) {
                    $hasConfig = $false
                    foreach ($config in $dnsConfig) {
                        if ($config.ServerAddresses) {
                            $hasConfig = $true
                            Write-Host "Giao thức: $($config.AddressFamily)"
                            Write-Host "Địa chỉ DNS Server:"
                            foreach ($dns in $config.ServerAddresses) {
                                Write-Host "  - $dns"
                            }
                        }
                    }
                    if (-not $hasConfig) {
                        Write-Host "Không có DNS Server được cấu hình cho adapter này." -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "Không tìm thấy cấu hình DNS cho adapter này." -ForegroundColor Yellow
                }
            }
        }
        elseif ($choice -eq "2") {
            # Thay đổi DNS
            Clear-Host
            Write-Host "`nDanh sách adapter mạng đang hoạt động:" -ForegroundColor Cyan
            $index = 1
            $adapterList = @{}
            foreach ($adapter in $adapters) {
                Write-Host "$index. $($adapter.Name)"
                $adapterList[$index] = $adapter
                $index++
            }

            $selection = Read-Host "`nNhập số thứ tự của adapter để thay đổi DNS (1-$($index-1)), hoặc 'q' để quay lại"
            if ($selection -eq 'q') {
                continue
            }

            if ($adapterList.ContainsKey([int]$selection)) {
                $selectedAdapter = $adapterList[[int]$selection]
                Clear-Host
                Write-Host "`nAdapter được chọn: $($selectedAdapter.Name)" -ForegroundColor Cyan
                Write-Host "----------------------------"

                # Hiển thị danh sách DNS công cộng
                Write-Host "`nCác DNS công cộng phổ biến:" -ForegroundColor Cyan
                foreach ($key in $dnsList.Keys | Sort-Object) {
                    Write-Host "$key. $($dnsList[$key].Name): $($dnsList[$key].IPv4)"
                }

                $dnsChoice = Read-Host "`nNhập số thứ tự của DNS để áp dụng (1-$($dnsList.Count)), hoặc 'q' để quay lại"
                if ($dnsChoice -eq 'q') {
                    continue
                }

                if ($dnsList.ContainsKey([int]$dnsChoice)) {
                    $selectedDNS = $dnsList[[int]$dnsChoice]
                    $ipv4DnsArray = $selectedDNS.IPv4.Split(',').Trim()
                    try {
                        # Thay đổi DNS
                        Set-DnsClientServerAddress -InterfaceIndex $selectedAdapter.InterfaceIndex -ServerAddresses $ipv4DnsArray -ErrorAction Stop
                        Write-Host "Đã cập nhật DNS cho adapter $($selectedAdapter.Name) thành $($selectedDNS.Name): $($selectedDNS.IPv4)" -ForegroundColor Green
                        Start-Sleep -Milliseconds 1000
                    } catch {
                        Write-Host "Lỗi khi thay đổi DNS: $_" -ForegroundColor Red
                        Read-Host -Prompt "Nhấn Enter để tiếp tục..."
                        continue
                    }

                    # Hiển thị thông tin DNS sau khi cập nhật
                    Write-Host "`nThông tin DNS sau khi cập nhật:" -ForegroundColor Cyan
                    try {
                        $dnsConfig = Get-DnsClientServerAddress -InterfaceIndex $selectedAdapter.InterfaceIndex -ErrorAction Stop
                    } catch {
                        Write-Host "Lỗi khi lấy thông tin DNS sau cập nhật: $_" -ForegroundColor Red
                        Read-Host -Prompt "Nhấn Enter để tiếp tục..."
                        continue
                    }
                    if ($dnsConfig) {
                        $hasConfig = $false
                        foreach ($config in $dnsConfig) {
                            if ($config.ServerAddresses) {
                                $hasConfig = $true
                                Write-Host "Giao thức: $($config.AddressFamily)"
                                Write-Host "Địa chỉ DNS Server:"
                                foreach ($dns in $config.ServerAddresses) {
                                    Write-Host "  - $dns"
                                }
                            }
                        }
                        if (-not $hasConfig) {
                            Write-Host "Không tìm thấy DNS Server được cấu hình cho adapter này sau khi cập nhật." -ForegroundColor Yellow
                        }
                    } else {
                        Write-Host "Không tìm thấy cấu hình DNS cho adapter này sau khi cập nhật." -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "Lựa chọn DNS không hợp lệ." -ForegroundColor Red
                }
            } else {
                Write-Host "Lựa chọn adapter không hợp lệ." -ForegroundColor Red
            }
        } else {
            Write-Host "Lựa chọn không hợp lệ." -ForegroundColor Red
        }

        Read-Host -Prompt "`nNhấn Enter để tiếp tục..."
    }

    Write-Host "`n=== KẾT THÚC ===" -ForegroundColor Green
} catch {
    Write-Host "Đã xảy ra lỗi: $_" -ForegroundColor Red
} finally {
    Read-Host -Prompt "Nhấn Enter để thoát..."
}
