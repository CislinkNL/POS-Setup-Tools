# ===============================================
# Install_RustDesk_Service.ps1
# 自动安装和配置 RustDesk 为 Windows 服务
# 使用 Cislink 预配置客户端
# ===============================================

# 检查管理员权限
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "❌ 需要管理员权限！请以管理员身份运行此脚本。" -ForegroundColor Red
    Write-Host "右键点击 PowerShell，选择'以管理员身份运行'" -ForegroundColor Yellow
    Pause
    Exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RustDesk 服务安装工具 (Cislink)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Cislink 预配置版本下载地址
$CislinkRustDeskUrl = "https://cislink.nl/radmin/RustDesk_Cislink_Setup.exe"
$TempInstallerPath = "$env:TEMP\RustDesk_Cislink_Setup.exe"
$RustDeskPath = "C:\Program Files\RustDesk\rustdesk.exe"

# 检查 RustDesk 是否已安装
if (-not (Test-Path $RustDeskPath)) {
    Write-Host "RustDesk 未安装，开始下载 Cislink 预配置版本..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "下载地址: $CislinkRustDeskUrl" -ForegroundColor Gray
    Write-Host "保存到: $TempInstallerPath" -ForegroundColor Gray
    Write-Host ""
    
    try {
        Write-Host "正在下载..." -ForegroundColor Cyan
        # 使用 .NET WebClient 下载（更可靠）
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($CislinkRustDeskUrl, $TempInstallerPath)
        Write-Host "✓ 下载完成" -ForegroundColor Green
        
        # 运行安装程序
        Write-Host ""
        Write-Host "正在安装 RustDesk..." -ForegroundColor Cyan
        Write-Host "（安装程序会自动运行，请等待安装完成）" -ForegroundColor Yellow
        
        Start-Process -FilePath $TempInstallerPath -Wait
        
        # 等待安装完成并验证
        Start-Sleep -Seconds 5
        
        if (Test-Path $RustDeskPath) {
            Write-Host "✓ RustDesk 安装成功" -ForegroundColor Green
            
            # 清理安装文件
            Remove-Item -Path $TempInstallerPath -Force -ErrorAction SilentlyContinue
        } else {
            Write-Error "❌ 安装失败：找不到 RustDesk 执行文件" -ForegroundColor Red
            Write-Host "请手动下载并安装: $CislinkRustDeskUrl" -ForegroundColor Yellow
            Pause
            Exit 1
        }
        
    } catch {
        Write-Error "❌ 下载/安装失败: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "请手动安装：" -ForegroundColor Yellow
        Write-Host "  1. 访问: $CislinkRustDeskUrl" -ForegroundColor Cyan
        Write-Host "  2. 下载并运行安装程序" -ForegroundColor Cyan
        Write-Host "  3. 重新运行此脚本" -ForegroundColor Cyan
        Write-Host ""
        Pause
        Exit 1
    }
} else {
    Write-Host "✓ 找到 RustDesk: $RustDeskPath" -ForegroundColor Green
    Write-Host "  （使用 Cislink 预配置版本，已包含服务器地址和密钥）" -ForegroundColor Gray
}

Write-Host "✓ 找到 RustDesk: $RustDeskPath" -ForegroundColor Green

# 步骤 1: 检查服务是否已存在
$existingService = Get-Service -Name "RustDesk" -ErrorAction SilentlyContinue
if ($existingService) {
    Write-Host ""
    Write-Host "⚠️  RustDesk 服务已存在" -ForegroundColor Yellow
    Write-Host "当前状态: $($existingService.Status)" -ForegroundColor Gray
    Write-Host "启动类型: $($existingService.StartType)" -ForegroundColor Gray
    Write-Host ""
    $reinstall = Read-Host "是否重新安装? (y/N)"
    if ($reinstall -ne 'y' -and $reinstall -ne 'Y') {
        Write-Host "取消安装。" -ForegroundColor Gray
        Pause
        Exit 0
    }
    
    # 卸载现有服务
    Write-Host ""
    Write-Host "正在卸载现有服务..." -ForegroundColor Yellow
    try {
        Stop-Service RustDesk -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        & $RustDeskPath --uninstall-service
        Start-Sleep -Seconds 2
        Write-Host "✓ 现有服务已卸载" -ForegroundColor Green
    } catch {
        Write-Warning "卸载过程中出现警告: $($_.Exception.Message)"
    }
}

# 步骤 2: 安装服务
Write-Host ""
Write-Host "[1/4] 正在安装 RustDesk 服务..." -ForegroundColor Cyan
try {
    & $RustDeskPath --install-service
    Start-Sleep -Seconds 2
    Write-Host "      ✓ 服务安装成功" -ForegroundColor Green
} catch {
    Write-Error "❌ 服务安装失败: $($_.Exception.Message)"
    Pause
    Exit 1
}

# 步骤 3: 配置服务
Write-Host ""
Write-Host "[2/4] 正在配置服务..." -ForegroundColor Cyan
try {
    Set-Service RustDesk -StartupType Automatic
    Write-Host "      ✓ 服务已设置为自动启动" -ForegroundColor Green
} catch {
    Write-Warning "设置自动启动失败: $($_.Exception.Message)"
}

# 步骤 4: 启动服务
Write-Host ""
Write-Host "[3/4] 正在启动服务..." -ForegroundColor Cyan
try {
    Start-Service RustDesk
    Start-Sleep -Seconds 3
    $serviceStatus = Get-Service RustDesk
    if ($serviceStatus.Status -eq 'Running') {
        Write-Host "      ✓ 服务已成功启动" -ForegroundColor Green
    } else {
        Write-Warning "服务状态: $($serviceStatus.Status)"
        Write-Host "      尝试重新启动..." -ForegroundColor Yellow
        Restart-Service RustDesk
        Start-Sleep -Seconds 2
    }
} catch {
    Write-Warning "启动服务失败: $($_.Exception.Message)"
    Write-Host "      您可以稍后手动启动服务" -ForegroundColor Yellow
}

# 步骤 5: 配置防火墙
Write-Host ""
Write-Host "[4/4] 正在配置防火墙..." -ForegroundColor Cyan
try {
    # 删除旧规则（如果存在）
    netsh advfirewall firewall delete rule name="RustDesk" 2>$null | Out-Null
    
    # 添加入站规则
    netsh advfirewall firewall add rule name="RustDesk" dir=in action=allow program="$RustDeskPath" enable=yes | Out-Null
    # 添加出站规则
    netsh advfirewall firewall add rule name="RustDesk" dir=out action=allow program="$RustDeskPath" enable=yes | Out-Null
    
    Write-Host "      ✓ 防火墙规则已配置" -ForegroundColor Green
} catch {
    Write-Warning "配置防火墙失败: $($_.Exception.Message)"
}

# 显示结果
Write-Host ""
Write-Host "=== 安装完成 ===" -ForegroundColor Green
Write-Host ""
Write-Host "📊 服务信息:" -ForegroundColor Cyan
$service = Get-Service RustDesk
Write-Host "  名称: $($service.Name)" -ForegroundColor Gray
Write-Host "  状态: $($service.Status)" -ForegroundColor $(if($service.Status -eq 'Running'){'Green'}else{'Yellow'})
Write-Host "  启动类型: $($service.StartType)" -ForegroundColor Gray
Write-Host "  显示名称: $($service.DisplayName)" -ForegroundColor Gray

Write-Host ""
Write-Host "🔧 管理命令:" -ForegroundColor Cyan
Write-Host "  启动服务: Start-Service RustDesk" -ForegroundColor Gray
Write-Host "  停止服务: Stop-Service RustDesk" -ForegroundColor Gray
Write-Host "  重启服务: Restart-Service RustDesk" -ForegroundColor Gray
Write-Host "  查看状态: Get-Service RustDesk" -ForegroundColor Gray

Write-Host ""
Write-Host "💡 重要提示:" -ForegroundColor Yellow
Write-Host "  • RustDesk 现在作为服务运行，即使用户注销也会保持运行" -ForegroundColor Gray
Write-Host "  • 可以通过 services.msc 管理服务" -ForegroundColor Gray
Write-Host "  • 打开 RustDesk 客户端查看连接 ID 和密码" -ForegroundColor Gray
Write-Host "  • 建议设置永久密码以便远程访问" -ForegroundColor Gray

Write-Host ""
Write-Host "🔐 设置永久密码 (可选):" -ForegroundColor Cyan
$setPassword = Read-Host "是否现在设置永久密码? (y/N)"
if ($setPassword -eq 'y' -or $setPassword -eq 'Y') {
    Write-Host ""
    $password = Read-Host "请输入密码 (至少6位)"
    if ($password.Length -ge 6) {
        try {
            & $RustDeskPath --password $password
            Write-Host "✓ 密码设置成功！" -ForegroundColor Green
        } catch {
            Write-Warning "设置密码失败: $($_.Exception.Message)"
        }
    } else {
        Write-Warning "密码太短，未设置"
    }
}

Write-Host ""
Write-Host "📖 查看完整指南: RustDesk_Service_Guide.md" -ForegroundColor Cyan
Write-Host ""
Pause
