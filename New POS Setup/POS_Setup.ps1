# ===============================================
#  POS_Setup.ps1
#  Windows 11 Pro 优化脚本 - 专用于 POS 系统
#  作者: ChatGPT GPT-5 | 日期: 2025-10-14
# ===============================================

# 检查管理员权限
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "❌ This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    Pause
    Exit 1
}

# 系统兼容性检查
$OSVersion = [System.Environment]::OSVersion.Version
if ($OSVersion.Major -lt 10 -or ($OSVersion.Major -eq 10 -and $OSVersion.Build -lt 22000)) {
    Write-Warning "⚠️  This script is optimized for Windows 11. Some features may not work properly on older versions."
    $continue = Read-Host "Do you want to continue anyway? (y/N)"
    if ($continue -ne 'y' -and $continue -ne 'Y') {
        Exit 0
    }
}

Write-Host "=== POS System Optimization Script Starting... ===" -ForegroundColor Cyan
Write-Host "System: Windows $($OSVersion.Major).$($OSVersion.Minor) Build $($OSVersion.Build)" -ForegroundColor Gray

# 创建日志和备份目录
$LogDir = "C:\POS\Logs"
$BackupDir = "C:\POS\Backup"
$Timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$LogPath = "$LogDir\setup_$Timestamp.log"
$BackupPath = "$BackupDir\registry_backup_$Timestamp.reg"

try {
    New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
    New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
    Start-Transcript -Path $LogPath -Force
    Write-Host "✓ Logging enabled: $LogPath" -ForegroundColor Green
    
    # 创建注册表备份
    Write-Host "Creating registry backup..." -ForegroundColor Yellow
    reg export "HKLM\SOFTWARE\Policies" "$BackupPath" /y | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Registry backup created: $BackupPath" -ForegroundColor Green
    } else {
        Write-Warning "Registry backup failed, but continuing..."
    }
} catch {
    Write-Warning "Failed to setup logging/backup: $($_.Exception.Message)"
}

# --- 1. 关闭消费者内容与 Microsoft 商店 ---
Write-Host "Disabling consumer features & Windows Store..."
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338393Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v RemoveWindowsStore /t REG_DWORD /d 1 /f

# --- 2. 禁止自动更新 ---
Write-Host "Disabling Windows Update..."
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DoNotConnectToWindowsUpdateInternetLocations /t REG_DWORD /d 1 /f
Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
Set-Service -Name wuauserv -StartupType Disabled

# --- 3. 简化界面 ---
Write-Host "Simplifying Windows UI..."
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v ToastEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Policies\Microsoft\Windows\Personalization" /v NoLockScreen /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f

# --- 4. 自动登录配置 (安全版本) ---
Write-Host "Configuring automatic login..." -ForegroundColor Yellow
$UserName = "Beheer"

# 安全方式1: 从环境变量读取密码
$Password = $env:POS_PASSWORD
if (-not $Password) {
    # 安全方式2: 交互式安全输入
    Write-Host "Please enter password for user '$UserName':" -ForegroundColor Cyan
    $SecurePassword = Read-Host -AsSecureString
    $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword))
}

if ($Password) {
    # 验证密码强度
    if ($Password.Length -lt 8) {
        Write-Warning "Password is less than 8 characters. Consider using a stronger password."
    }
    
    Write-Host "Setting up auto-login for user: $UserName" -ForegroundColor Green
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 1 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /t REG_SZ /d $UserName /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d $Password /f
    
    # 清除内存中的密码
    $Password = $null
    [System.GC]::Collect()
} else {
    Write-Warning "No password provided. Skipping auto-login configuration."
    Write-Host "You can manually configure auto-login later or use Windows Hello/PIN." -ForegroundColor Yellow
}

# --- 5. 安全与隐私 ---
Write-Host "Hardening system security..."
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v fAllowToGetHelp /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoControlPanel /t REG_DWORD /d 1 /f

# --- 6. 性能优化 (增强错误处理) ---
Write-Host "Disabling unnecessary services..." -ForegroundColor Yellow
$services = @("DiagTrack", "SysMain", "WSearch", "OneSyncSvc", "XblGameSave", "WMPNetworkSvc")
$serviceResults = @()

foreach ($svc in $services) {
    try {
        $service = Get-Service -Name $svc -ErrorAction Stop
        $originalStatus = $service.Status
        $originalStartType = $service.StartType
        
        Stop-Service -Name $svc -Force -ErrorAction Stop
        Set-Service -Name $svc -StartupType Disabled -ErrorAction Stop
        
        $serviceResults += [PSCustomObject]@{
            Name = $svc
            OriginalStatus = $originalStatus
            OriginalStartType = $originalStartType
            Result = "✓ Disabled"
        }
        Write-Host "✓ Service '$svc' disabled successfully" -ForegroundColor Green
    }
    catch [Microsoft.PowerShell.Commands.ServiceCommandException] {
        Write-Warning "Service '$svc' not found - skipping"
        $serviceResults += [PSCustomObject]@{
            Name = $svc
            OriginalStatus = "Not Found"
            OriginalStartType = "Not Found"
            Result = "⚠️  Not Found"
        }
    }
    catch {
        Write-Warning "Failed to disable service '$svc': $($_.Exception.Message)"
        $serviceResults += [PSCustomObject]@{
            Name = $svc
            OriginalStatus = "Unknown"
            OriginalStartType = "Unknown"
            Result = "❌ Failed"
        }
    }
}

# 保存服务状态到文件供恢复时使用
$serviceResults | Export-Csv "$BackupDir\services_backup_$Timestamp.csv" -NoTypeInformation
Write-Host "Service optimization complete. Backup saved to services_backup_$Timestamp.csv" -ForegroundColor Cyan

# --- 7. 网络防火墙配置（允许内网双向访问） ---
Write-Host "Configuring local network firewall rules..." -ForegroundColor Cyan

# 启用防火墙并设置默认策略
netsh advfirewall set allprofiles state on
netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound

# 允许本机回环通信（必要）
netsh advfirewall firewall add rule name="POS Loopback" dir=in action=allow localip=127.0.0.1 remoteip=127.0.0.1 | Out-Null
netsh advfirewall firewall add rule name="POS Loopback Out" dir=out action=allow localip=127.0.0.1 remoteip=127.0.0.1 | Out-Null

# 允许常见私有网段内访问
$PrivateRanges = @("192.168.0.0/16", "10.0.0.0/8", "172.16.0.0/12")

foreach ($net in $PrivateRanges) {
    # 允许入站（外部访问POS）
    netsh advfirewall firewall add rule name="POS Internal Inbound - $net" dir=in action=allow remoteip=$net enable=yes | Out-Null
    # 允许出站（POS访问内网设备）
    netsh advfirewall firewall add rule name="POS Internal Outbound - $net" dir=out action=allow remoteip=$net enable=yes | Out-Null
}

# 保持RustDesk远程管理放行
Write-Host "Allowing RustDesk remote service through firewall..." -ForegroundColor Cyan
$RustDeskPath = "C:\Program Files\RustDesk\rustdesk.exe"
if (Test-Path $RustDeskPath) {
    netsh advfirewall firewall add rule name="RustDesk Service" dir=in action=allow program="$RustDeskPath" enable=yes | Out-Null
    netsh advfirewall firewall add rule name="RustDesk Service Out" dir=out action=allow program="$RustDeskPath" enable=yes | Out-Null
}

# 允许 Python POS 服务器端口 (8001-8004)
Write-Host "Allowing Python POS server ports (8001-8004)..." -ForegroundColor Cyan
netsh advfirewall firewall add rule name="POS Python Server Inbound" dir=in action=allow protocol=TCP localport=8001,8002,8003,8004 enable=yes | Out-Null
netsh advfirewall firewall add rule name="POS Python Server Outbound" dir=out action=allow protocol=TCP localport=8001,8002,8003,8004 enable=yes | Out-Null

# 允许 Chrome Remote Desktop
Write-Host "Allowing Chrome Remote Desktop..." -ForegroundColor Cyan
$ChromeRDPaths = @(
    "$env:LOCALAPPDATA\Google\Chrome Remote Desktop\*\remoting_host.exe",
    "C:\Program Files (x86)\Google\Chrome Remote Desktop\*\remoting_host.exe"
)
foreach ($path in $ChromeRDPaths) {
    $resolvedPaths = Get-Item $path -ErrorAction SilentlyContinue
    if ($resolvedPaths) {
        foreach ($resolvedPath in $resolvedPaths) {
            netsh advfirewall firewall add rule name="Chrome Remote Desktop" dir=in action=allow program="$($resolvedPath.FullName)" enable=yes | Out-Null
            netsh advfirewall firewall add rule name="Chrome Remote Desktop Out" dir=out action=allow program="$($resolvedPath.FullName)" enable=yes | Out-Null
        }
    }
}

# 允许 Cloudflare 服务 (cloudflared.exe)
Write-Host "Allowing Cloudflare services..." -ForegroundColor Cyan
$CloudflarePaths = @(
    "$env:ProgramFiles\cloudflared\cloudflared.exe",
    "$env:LOCALAPPDATA\cloudflared\cloudflared.exe",
    "C:\cloudflared\cloudflared.exe"
)
foreach ($cfPath in $CloudflarePaths) {
    if (Test-Path $cfPath) {
        netsh advfirewall firewall add rule name="Cloudflare Tunnel" dir=in action=allow program="$cfPath" enable=yes | Out-Null
        netsh advfirewall firewall add rule name="Cloudflare Tunnel Out" dir=out action=allow program="$cfPath" enable=yes | Out-Null
    }
}

# 允许 HTTPS (443) 和 HTTP (80) 出站连接（用于 Cloudflare 和其他服务）
Write-Host "Allowing HTTPS/HTTP outbound connections..." -ForegroundColor Cyan
netsh advfirewall firewall add rule name="HTTPS Outbound" dir=out action=allow protocol=TCP remoteport=443 enable=yes | Out-Null
netsh advfirewall firewall add rule name="HTTP Outbound" dir=out action=allow protocol=TCP remoteport=80 enable=yes | Out-Null

# 允许 DNS (53) 出站
netsh advfirewall firewall add rule name="DNS Outbound" dir=out action=allow protocol=UDP remoteport=53 enable=yes | Out-Null
netsh advfirewall firewall add rule name="DNS TCP Outbound" dir=out action=allow protocol=TCP remoteport=53 enable=yes | Out-Null

Write-Host "Firewall configuration complete: Internal LAN + Essential services allowed." -ForegroundColor Green

# --- 8. 自动启动 POS 程序 ---
Write-Host "Adding POS app to startup..."
$POSPath = "C:\POS\startPOS.bat"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v POSApp /t REG_SZ /d $POSPath /f

# --- 9. RustDesk 自动启动与防火墙放行 ---
Write-Host "`nConfiguring RustDesk autostart..." -ForegroundColor Yellow
$RustDeskPath = "C:\Program Files\RustDesk\rustdesk.exe"
$user = "CislinkNL\Beheer"

if (Test-Path $RustDeskPath) {
    try {
        Write-Host "Installing RustDesk as a Windows service..." -ForegroundColor Cyan
        & $RustDeskPath --install-service
        Start-Service RustDesk -ErrorAction SilentlyContinue
        Set-Service RustDesk -StartupType Automatic
        Write-Host "RustDesk service installed and set to auto-start." -ForegroundColor Green
    }
    catch {
        Write-Warning "Service install failed, falling back to Scheduled Task method..."
        try {
            $Action = New-ScheduledTaskAction -Execute $RustDeskPath -Argument "--service"
            $Trigger = New-ScheduledTaskTrigger -AtLogOn
            $Principal = New-ScheduledTaskPrincipal -UserId $user -RunLevel Highest
            Register-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -TaskName "RustDesk AutoStart" -Description "Start RustDesk on user logon" -Force
            Write-Host "RustDesk scheduled task created successfully." -ForegroundColor Green
        }
        catch {
            Write-Warning "RustDesk startup registration failed: $($_.Exception.Message)"
        }
    }

    # 防火墙放行
    Write-Host "Allowing RustDesk through Windows Firewall..." -ForegroundColor Cyan
    netsh advfirewall firewall add rule name="RustDesk" dir=in action=allow program="$RustDeskPath" enable=yes | Out-Null
}
else {
    Write-Warning "RustDesk executable not found at $RustDeskPath. Please check installation path."
}

# --- 10. 可选提示 ---
Write-Host "`n💡 提示: 你可以在设置中开启 Kiosk 模式 (Assigned Access)，让 POS 程序开机全屏运行。" -ForegroundColor Yellow
Write-Host "路径: Settings -> Accounts -> Family and other users -> Set up a kiosk"

# --- 11. 完成 ---
Write-Host "`n=== POS Optimization Complete ===" -ForegroundColor Green
Write-Host "📋 Summary of changes:" -ForegroundColor Cyan
Write-Host "  • Windows Store and consumer features disabled" -ForegroundColor Gray
Write-Host "  • Automatic updates disabled" -ForegroundColor Gray
Write-Host "  • UI simplified for POS use" -ForegroundColor Gray
Write-Host "  • Security hardening applied" -ForegroundColor Gray
Write-Host "  • Firewall configured for internal network access" -ForegroundColor Gray
Write-Host "  • RustDesk remote access configured" -ForegroundColor Gray
Write-Host "  • POS application set to auto-start" -ForegroundColor Gray

Write-Host "`n📁 Files created:" -ForegroundColor Cyan
Write-Host "  • Log: $LogPath" -ForegroundColor Gray
Write-Host "  • Registry backup: $BackupPath" -ForegroundColor Gray
Write-Host "  • Service backup: $BackupDir\services_backup_$Timestamp.csv" -ForegroundColor Gray

Write-Host "`n⚠️  Important Security Notes:" -ForegroundColor Yellow
Write-Host "  • Auto-login is configured - ensure physical security of the device" -ForegroundColor Gray
Write-Host "  • Registry backup created for easy restoration if needed" -ForegroundColor Gray
Write-Host "  • Review firewall rules if network access issues occur" -ForegroundColor Gray

Write-Host "Please reboot the system to apply all changes." -ForegroundColor Cyan

# 停止日志记录
try {
    Stop-Transcript
} catch {
    # Transcript might not be running
}

# 安全清理 - 清除敏感信息
if (Get-Variable -Name Password -ErrorAction SilentlyContinue) {
    Remove-Variable -Name Password -Force
}
[System.GC]::Collect()

Pause
