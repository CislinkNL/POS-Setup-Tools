# ============================================================================
# 启用内网文件共享和网络发现
# 用途: 配置网络为专用，启用文件共享、打印机共享、网络发现
# 适用: POS 内网环境、办公室局域网
# ============================================================================

#Requires -RunAsAdministrator

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  启用内网文件共享和网络发现" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 获取活动的网络适配器
$ActiveAdapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}

if ($ActiveAdapters.Count -eq 0) {
    Write-Host "❌ 错误：没有找到活动的网络适配器" -ForegroundColor Red
    exit 1
}

Write-Host "找到 $($ActiveAdapters.Count) 个活动网络适配器：" -ForegroundColor Yellow
$ActiveAdapters | ForEach-Object {
    Write-Host "  - $($_.Name) ($($_.InterfaceDescription))" -ForegroundColor Gray
}
Write-Host ""

# 如果有多个适配器，让用户选择
if ($ActiveAdapters.Count -gt 1) {
    Write-Host "请选择要配置的网络适配器（输入序号）：" -ForegroundColor Yellow
    for ($i = 0; $i -lt $ActiveAdapters.Count; $i++) {
        Write-Host "  [$($i + 1)] $($ActiveAdapters[$i].Name)" -ForegroundColor Gray
    }
    
    $selection = Read-Host "输入序号 (1-$($ActiveAdapters.Count))"
    $selectedIndex = [int]$selection - 1
    
    if ($selectedIndex -lt 0 -or $selectedIndex -ge $ActiveAdapters.Count) {
        Write-Host "❌ 无效的选择" -ForegroundColor Red
        exit 1
    }
    
    $InterfaceAlias = $ActiveAdapters[$selectedIndex].Name
} else {
    $InterfaceAlias = $ActiveAdapters[0].Name
}

Write-Host ""
Write-Host "将配置网络适配器: $InterfaceAlias" -ForegroundColor Green
Write-Host ""

# 1. 设置网络为专用
try {
    Write-Host "[1/5] 设置网络类型为专用..." -ForegroundColor Cyan
    Set-NetConnectionProfile -InterfaceAlias $InterfaceAlias -NetworkCategory Private -ErrorAction Stop
    Write-Host "      ✓ 网络已设置为专用网络" -ForegroundColor Green
} catch {
    Write-Host "      ⚠ 警告：无法设置网络类型 - $($_.Exception.Message)" -ForegroundColor Yellow
}

# 2. 启用网络发现
try {
    Write-Host "[2/5] 启用网络发现..." -ForegroundColor Cyan
    netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes | Out-Null
    Write-Host "      ✓ 网络发现已启用（可以看到其他设备）" -ForegroundColor Green
} catch {
    Write-Host "      ⚠ 警告：无法启用网络发现 - $($_.Exception.Message)" -ForegroundColor Yellow
}

# 3. 启用文件和打印机共享
try {
    Write-Host "[3/5] 启用文件和打印机共享..." -ForegroundColor Cyan
    netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes | Out-Null
    Write-Host "      ✓ 文件和打印机共享已启用" -ForegroundColor Green
} catch {
    Write-Host "      ⚠ 警告：无法启用文件共享 - $($_.Exception.Message)" -ForegroundColor Yellow
}

# 4. 启用 SMB 文件共享服务
try {
    Write-Host "[4/5] 配置 SMB 文件共享服务..." -ForegroundColor Cyan
    # 禁用不安全的 SMB1
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force -WarningAction SilentlyContinue
    # 启用 SMB2/3
    Set-SmbServerConfiguration -EnableSMB2Protocol $true -Force -WarningAction SilentlyContinue
    Write-Host "      ✓ SMB 文件共享已配置（SMB1 已禁用，SMB2/3 已启用）" -ForegroundColor Green
} catch {
    Write-Host "      ⚠ 警告：无法配置 SMB - $($_.Exception.Message)" -ForegroundColor Yellow
}

# 5. 启动网络发现相关服务
try {
    Write-Host "[5/5] 启动网络发现服务..." -ForegroundColor Cyan
    
    $services = @("FDResPub", "SSDPSRV", "upnphost")
    foreach ($svc in $services) {
        $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if ($service) {
            if ($service.Status -ne "Running") {
                Set-Service -Name $svc -StartupType Automatic -ErrorAction SilentlyContinue
                Start-Service -Name $svc -ErrorAction SilentlyContinue
            }
        }
    }
    
    Write-Host "      ✓ 网络发现服务已启动" -ForegroundColor Green
} catch {
    Write-Host "      ⚠ 警告：部分服务启动失败 - $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  ✅ 内网共享配置完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# 显示当前配置
Write-Host "当前网络配置：" -ForegroundColor Cyan
$profile = Get-NetConnectionProfile -InterfaceAlias $InterfaceAlias
Write-Host "  网络类型: $($profile.NetworkCategory)" -ForegroundColor Gray
Write-Host "  网络名称: $($profile.Name)" -ForegroundColor Gray
Write-Host ""

Write-Host "现在可以：" -ForegroundColor Yellow
Write-Host "  ✓ 在文件资源管理器中看到其他设备" -ForegroundColor Gray
Write-Host "  ✓ 访问共享文件夹: \\计算机名\共享名" -ForegroundColor Gray
Write-Host "  ✓ 使用网络打印机" -ForegroundColor Gray
Write-Host "  ✓ 共享本机文件夹给其他设备" -ForegroundColor Gray
Write-Host ""

Write-Host "提示：" -ForegroundColor Yellow
Write-Host "  - 在文件资源管理器左侧可以看到'网络'" -ForegroundColor Gray
Write-Host "  - 要共享文件夹：右键文件夹 → 属性 → 共享" -ForegroundColor Gray
Write-Host "  - 访问共享：Win + R → \\其他电脑名" -ForegroundColor Gray
Write-Host ""

Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
