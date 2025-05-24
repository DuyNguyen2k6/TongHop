# Script PowerShell de xem va thay doi DNS
# Chay tren Windows Terminal neu co, neu khong chay tren PowerShell
# Tu dong yeu cau quyen Administrator, lam moi man hinh, dat kich thuoc cua so nho hon
# Sua loi hien thi DNS sau khi thay doi
# Kiểm tra quyền Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    try {
        # Nếu chưa có quyền admin, tự động mở lại script với quyền admin (chạy inline nên chỉ cần chạy lại nội dung)
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


# Dat kich thuoc cua so PowerShell (neu chay tren PowerShell)
try {
    if (-not (Get-Command wt -ErrorAction SilentlyContinue)) {
        # Dat kich thuoc cua so (chieu rong: 80 cot, chieu cao: 25 dong)
        [Console]::WindowWidth = 80
        [Console]::WindowHeight = 25
        [Console]::BufferWidth = 80
        [Console]::BufferHeight = 300
    }
} catch {
    Write-Host "Loi khi dat kich thuoc cua so: $_" -ForegroundColor Red
}

try {
    # Danh sach DNS cong cong
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
        # Lam moi man hinh truoc khi hien thi menu
        Clear-Host
        Write-Host "`n=== QUAN LY DNS ===" -ForegroundColor Green
        Write-Host "1. Hien thi thong tin DNS"
        Write-Host "2. Thay doi DNS"
        Write-Host "3. Thoat"
        $choice = Read-Host "`nNhap lua chon (1-3)"

        if ($choice -eq "3") {
            Clear-Host
            Write-Host "Thoat chuong trinh." -ForegroundColor Yellow
            break
        }

        # Lay tat ca cac adapter mang dang hoat dong
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

        if (-not $adapters) {
            Write-Host "Khong tim thay adapter mang nao dang hoat dong." -ForegroundColor Red
            Read-Host -Prompt "Nhan Enter de tiep tuc..."
            continue
        }

        if ($choice -eq "1") {
            # Hien thi thong tin DNS
            Clear-Host
            Write-Host "`n=== THONG TIN CAU HINH DNS ===" -ForegroundColor Green
            foreach ($adapter in $adapters) {
                Write-Host "`nAdapter: $($adapter.Name)" -ForegroundColor Cyan
                Write-Host "----------------------------"
                
                # Lay thong tin DNS tu adapter
                try {
                    $dnsConfig = Get-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ErrorAction Stop
                } catch {
                    Write-Host "Loi khi lay thong tin DNS: $_" -ForegroundColor Red
                    continue
                }
                
                if ($dnsConfig) {
                    $hasConfig = $false
                    foreach ($config in $dnsConfig) {
                        if ($config.ServerAddresses) {
                            $hasConfig = $true
                            Write-Host "Giao thuc: $($config.AddressFamily)"
                            Write-Host "Dia chi DNS Server:"
                            foreach ($dns in $config.ServerAddresses) {
                                Write-Host "  - $dns"
                            }
                        }
                    }
                    if (-not $hasConfig) {
                        Write-Host "Khong co DNS Server duoc cau hinh cho adapter nay." -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "Khong tim thay cau hinh DNS cho adapter nay." -ForegroundColor Yellow
                }
            }
        }
        elseif ($choice -eq "2") {
            # Thay doi DNS
            Clear-Host
            Write-Host "`nDanh sach adapter mang dang hoat dong:" -ForegroundColor Cyan
            $index = 1
            $adapterList = @{}
            foreach ($adapter in $adapters) {
                Write-Host "$index. $($adapter.Name)"
                $adapterList[$index] = $adapter
                $index++
            }

            $selection = Read-Host "`nNhap so thu tu cua adapter de thay doi DNS (1-$($index-1)), hoac 'q' de quay lai"
            if ($selection -eq 'q') {
                continue
            }

            if ($adapterList.ContainsKey([int]$selection)) {
                $selectedAdapter = $adapterList[[int]$selection]
                Clear-Host
                Write-Host "`nAdapter duoc chon: $($selectedAdapter.Name)" -ForegroundColor Cyan
                Write-Host "----------------------------"

                # Hien thi danh sach DNS cong cong
                Write-Host "`nCac DNS cong cong pho bien:" -ForegroundColor Cyan
                foreach ($key in $dnsList.Keys | Sort-Object) {
                    Write-Host "$key. $($dnsList[$key].Name): $($dnsList[$key].IPv4)"
                }

                $dnsChoice = Read-Host "`nNhap so thu tu cua DNS de ap dung (1-$($dnsList.Count)), hoac 'q' de quay lai"
                if ($dnsChoice -eq 'q') {
                    continue
                }

                if ($dnsList.ContainsKey([int]$dnsChoice)) {
                    $selectedDNS = $dnsList[[int]$dnsChoice]
                    $ipv4DnsArray = $selectedDNS.IPv4.Split(',').Trim()
                    try {
                        # Thay doi DNS
                        Set-DnsClientServerAddress -InterfaceIndex $selectedAdapter.InterfaceIndex -ServerAddresses $ipv4DnsArray -ErrorAction Stop
                        Write-Host "Da cap nhat DNS cho adapter $($selectedAdapter.Name) thanh $($selectedDNS.Name): $($selectedDNS.IPv4)" -ForegroundColor Green
                        # Cho 1 giay de dam bao cau hinh duoc ap dung
                        Start-Sleep -Milliseconds 1000
                    } catch {
                        Write-Host "Loi khi thay doi DNS: $_" -ForegroundColor Red
                        Read-Host -Prompt "Nhan Enter de tiep tuc..."
                        continue
                    }

                    # Hien thi thong tin DNS sau khi cap nhat
                    Write-Host "`nThong tin DNS sau khi cap nhat:" -ForegroundColor Cyan
                    try {
                        $dnsConfig = Get-DnsClientServerAddress -InterfaceIndex $selectedAdapter.InterfaceIndex -ErrorAction Stop
                    } catch {
                        Write-Host "Loi khi lay thong tin DNS sau cap nhat: $_" -ForegroundColor Red
                        Read-Host -Prompt "Nhan Enter de tiep tuc..."
                        continue
                    }
                    if ($dnsConfig) {
                        $hasConfig = $false
                        foreach ($config in $dnsConfig) {
                            if ($config.ServerAddresses) {
                                $hasConfig = $true
                                Write-Host "Giao thuc: $($config.AddressFamily)"
                                Write-Host "Dia chi DNS Server:"
                                foreach ($dns in $config.ServerAddresses) {
                                    Write-Host "  - $dns"
                                }
                            }
                        }
                        if (-not $hasConfig) {
                            Write-Host "Khong tim thay DNS Server duoc cau hinh cho adapter nay sau khi cap nhat." -ForegroundColor Yellow
                        }
                    } else {
                        Write-Host "Khong tim thay cau hinh DNS cho adapter nay sau khi cap nhat." -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "Lua chon DNS khong hop le." -ForegroundColor Red
                }
            } else {
                Write-Host "Lua chon adapter khong hop le." -ForegroundColor Red
            }
        } else {
            Write-Host "Lua chon khong hop le." -ForegroundColor Red
        }

        Read-Host -Prompt "`nNhan Enter de tiep tuc..."
    }

    Write-Host "`n=== KET THUC ===" -ForegroundColor Green
} catch {
    Write-Host "Da xay ra loi: $_" -ForegroundColor Red
} finally {
    Read-Host -Prompt "Nhan Enter de thoat..."
}
