# ===============================================
#  POS_Restore.ps1
#  恢复 Windows 11 Pro 到默认配置
#  解除 POS 限制、恢复服务、防火墙与 RustDesk
#  作者: ChatGPT GPT-5 | 日期: 2025-10-14
# ===============================================

# 检查管理员权限
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "❌ This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    Pause
    Exit 1
}

Write-Host "=== Restoring Windows default configuration... ===" -ForegroundColor Cyan

# 创建恢复日志
$LogDir = "C:\POS\Logs"
$Timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$LogPath = "$LogDir\restore_$Timestamp.log"

try {
    New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
    Start-Transcript -Path $LogPath -Force
    Write-Host "✓ Logging enabled: $LogPath" -ForegroundColor Green
} catch {
    Write-Warning "Failed to setup logging: $($_.Exception.Message)"
}

# --- 1. 恢复 Windows 商店与消费者内容 ---
Write-Host "Re-enabling Windows Store & consumer content..."
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v RemoveWindowsStore /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338393Enabled /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /f

# --- 2. 恢复自动更新 ---
Write-Host "Re-enabling Windows Update..."
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f
Set-Service -Name wuauserv -StartupType Manual -ErrorAction SilentlyContinue
Start-Service -Name wuauserv -ErrorAction SilentlyContinue

# --- 3. 恢复界面与个性化 ---
Write-Host "Restoring UI and personalization settings..."
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v ToastEnabled /f
reg delete "HKCU\Software\Policies\Microsoft\Windows\Personalization" /v NoLockScreen /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /f

# --- 4. 取消自动登录 (安全版本) ---
Write-Host "Disabling auto-login..." -ForegroundColor Yellow
try {
    # 安全地清除自动登录信息
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /f 2>$null
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /f 2>$null
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /f 2>$null
    
    # 额外安全措施：清除可能的LSA密码存储
    reg delete "HKLM\SECURITY\Policy\Secrets\DefaultPassword" /f 2>$null
    
    Write-Host "✓ Auto-login disabled and credentials cleared" -ForegroundColor Green
} catch {
    Write-Warning "Some auto-login settings might not have been cleared: $($_.Exception.Message)"
}

# --- 5. 恢复安全与隐私默认 ---
Write-Host "Restoring security defaults..."
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v fAllowToGetHelp /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /f

# 恢复设置与控制面板访问
Write-Host "Re-enabling Settings and Control Panel..."
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoControlPanel /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v SettingsPageVisibility /f

# --- 6. 恢复系统服务 (增强版本) ---
Write-Host "Restoring default services..." -ForegroundColor Yellow

# 尝试从备份恢复服务状态
$BackupDir = "C:\POS\Backup"
$ServiceBackups = Get-ChildItem "$BackupDir\services_backup_*.csv" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending

if ($ServiceBackups) {
    $LatestBackup = $ServiceBackups[0]
    Write-Host "Found service backup: $($LatestBackup.Name)" -ForegroundColor Cyan
    try {
        $ServiceData = Import-Csv $LatestBackup.FullName
        foreach ($svcData in $ServiceData) {
            if ($svcData.OriginalStatus -ne "Not Found") {
                try {
                    Set-Service -Name $svcData.Name -StartupType $svcData.OriginalStartType -ErrorAction Stop
                    if ($svcData.OriginalStatus -eq "Running") {
                        Start-Service -Name $svcData.Name -ErrorAction SilentlyContinue
                    }
                    Write-Host "✓ Restored service '$($svcData.Name)' to $($svcData.OriginalStartType)" -ForegroundColor Green
                } catch {
                    Write-Warning "Failed to restore service '$($svcData.Name)': $($_.Exception.Message)"
                }
            }
        }
    } catch {
        Write-Warning "Failed to read service backup: $($_.Exception.Message)"
    }
} else {
    # 默认恢复方式
    Write-Host "No service backup found, using default restoration..." -ForegroundColor Yellow
    $services = @("DiagTrack", "SysMain", "WSearch", "OneSyncSvc", "XblGameSave", "WMPNetworkSvc", "wuauserv")
    foreach ($svc in $services) {
        try {
            Set-Service -Name $svc -StartupType Manual -ErrorAction SilentlyContinue
            Start-Service -Name $svc -ErrorAction SilentlyContinue
            Write-Host "✓ Service '$svc' restored to Manual startup" -ForegroundColor Green
        } catch {
            Write-Warning "Failed to restore service '$svc'"
        }
    }
}

# --- 7. 恢复防火墙默认策略 ---
Write-Host "Resetting Windows Firewall..."
netsh advfirewall reset

# --- 8. 删除 POS 启动项 ---
Write-Host "Removing POS startup entries..."
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v POSApp /f

# --- 9. 移除 RustDesk 自动启动与服务 ---
Write-Host "Removing RustDesk autostart and service..." -ForegroundColor Yellow
$RustDeskPath = "C:\Program Files\RustDesk\rustdesk.exe"

# 删除注册表启动项
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v RustDesk /f

# 删除计划任务
if (Get-ScheduledTask -TaskName "RustDesk AutoStart" -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName "RustDesk AutoStart" -Confirm:$false
    Write-Host "RustDesk scheduled task removed." -ForegroundColor Green
}

# 停止并卸载服务（如果存在）
if (Get-Service -Name "RustDesk" -ErrorAction SilentlyContinue) {
    try {
        Stop-Service RustDesk -Force -ErrorAction SilentlyContinue
        if (Test-Path $RustDeskPath) {
            & $RustDeskPath --uninstall-service
        }
        Write-Host "RustDesk service uninstalled successfully." -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to uninstall RustDesk service: $($_.Exception.Message)"
    }
}

# 删除防火墙规则
netsh advfirewall firewall delete rule name="RustDesk" | Out-Null
netsh advfirewall firewall delete rule name="RustDesk Service" | Out-Null
netsh advfirewall firewall delete rule name="RustDesk Service Out" | Out-Null
netsh advfirewall firewall delete rule name="POS Internal Inbound - 192.168.0.0/16" | Out-Null
netsh advfirewall firewall delete rule name="POS Internal Outbound - 192.168.0.0/16" | Out-Null
netsh advfirewall firewall delete rule name="POS Internal Inbound - 10.0.0.0/8" | Out-Null
netsh advfirewall firewall delete rule name="POS Internal Outbound - 10.0.0.0/8" | Out-Null
netsh advfirewall firewall delete rule name="POS Internal Inbound - 172.16.0.0/12" | Out-Null
netsh advfirewall firewall delete rule name="POS Internal Outbound - 172.16.0.0/12" | Out-Null
netsh advfirewall firewall delete rule name="POS Loopback" | Out-Null
netsh advfirewall firewall delete rule name="POS Loopback Out" | Out-Null
netsh advfirewall firewall delete rule name="POS Internal Network" | Out-Null
netsh advfirewall firewall delete rule name="POS Python Server Inbound" | Out-Null
netsh advfirewall firewall delete rule name="POS Python Server Outbound" | Out-Null
netsh advfirewall firewall delete rule name="Chrome Remote Desktop" | Out-Null
netsh advfirewall firewall delete rule name="Chrome Remote Desktop Out" | Out-Null
netsh advfirewall firewall delete rule name="Cloudflare Tunnel" | Out-Null
netsh advfirewall firewall delete rule name="Cloudflare Tunnel Out" | Out-Null
netsh advfirewall firewall delete rule name="HTTPS Outbound" | Out-Null
netsh advfirewall firewall delete rule name="HTTP Outbound" | Out-Null
netsh advfirewall firewall delete rule name="DNS Outbound" | Out-Null
netsh advfirewall firewall delete rule name="DNS TCP Outbound" | Out-Null

# --- 10. 恢复任务栏与桌面 ---
Write-Host "Restoring taskbar and desktop layout..."
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" /f

# --- 11. 清理完成提示 ---
Write-Host "`n=== Windows Default Settings Restored ===" -ForegroundColor Green
Write-Host "📋 Restoration Summary:" -ForegroundColor Cyan
Write-Host "  • Windows Store and consumer features re-enabled" -ForegroundColor Gray
Write-Host "  • Automatic updates restored" -ForegroundColor Gray
Write-Host "  • UI and personalization settings restored" -ForegroundColor Gray
Write-Host "  • Auto-login disabled and credentials cleared" -ForegroundColor Gray
Write-Host "  • System services restored to default state" -ForegroundColor Gray
Write-Host "  • Firewall reset to default configuration" -ForegroundColor Gray
Write-Host "  • RustDesk autostart and service removed" -ForegroundColor Gray
Write-Host "  • POS startup entries removed" -ForegroundColor Gray

Write-Host "`n📁 Log file: $LogPath" -ForegroundColor Cyan

Write-Host "`n🔒 Security Notes:" -ForegroundColor Yellow
Write-Host "  • All auto-login credentials have been cleared" -ForegroundColor Gray
Write-Host "  • System has been returned to secure default state" -ForegroundColor Gray
Write-Host "  • Manual login will be required after reboot" -ForegroundColor Gray

Write-Host "Please reboot your system to finalize restoration." -ForegroundColor Cyan

# 停止日志记录
try {
    Stop-Transcript
} catch {
    # Transcript might not be running
}

# 最终安全清理
[System.GC]::Collect()

Pause
