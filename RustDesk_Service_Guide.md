# 🖥️ RustDesk 服务安装和管理指南

## 📋 概述

RustDesk 是一个开源的远程桌面软件，支持作为 Windows 服务运行。安装为服务后，即使没有用户登录，也能进行远程访问和管理。

---

## 🚀 快速安装（推荐方法）

### 方法 1: 使用 POS Setup 脚本（自动配置）

POS Setup 脚本已包含 RustDesk 服务的自动安装和配置：

```batch
cd "New POS Setup"
POS_Setup.bat
```

脚本会自动：
- ✅ 安装 RustDesk 为 Windows 服务
- ✅ 设置服务自动启动
- ✅ 配置防火墙规则
- ✅ 启动服务

---

## 🔧 手动安装 RustDesk 服务

### 前提条件

1. **下载 RustDesk**
   - 官方网站: https://rustdesk.com/
   - 或从 GitHub: https://github.com/rustdesk/rustdesk/releases
   - 下载 Windows 安装包（.exe 文件）

2. **安装 RustDesk**
   - 运行安装程序
   - 默认安装路径: `C:\Program Files\RustDesk\rustdesk.exe`
   - 完成安装

### 步骤 1: 安装为 Windows 服务

**以管理员身份运行 PowerShell**，执行以下命令：

```powershell
# 设置 RustDesk 路径
$RustDeskPath = "C:\Program Files\RustDesk\rustdesk.exe"

# 安装为服务
& $RustDeskPath --install-service

# 启动服务
Start-Service RustDesk

# 设置为自动启动
Set-Service RustDesk -StartupType Automatic

Write-Host "✓ RustDesk 服务安装完成！" -ForegroundColor Green
```

### 步骤 2: 配置防火墙规则

```powershell
# 允许 RustDesk 通过防火墙
$RustDeskPath = "C:\Program Files\RustDesk\rustdesk.exe"
netsh advfirewall firewall add rule name="RustDesk" dir=in action=allow program="$RustDeskPath" enable=yes
netsh advfirewall firewall add rule name="RustDesk" dir=out action=allow program="$RustDeskPath" enable=yes

Write-Host "✓ 防火墙规则已配置！" -ForegroundColor Green
```

### 步骤 3: 验证安装

```powershell
# 检查服务状态
Get-Service RustDesk

# 查看服务详细信息
Get-Service RustDesk | Select-Object Name, Status, StartType, DisplayName

# 检查防火墙规则
netsh advfirewall firewall show rule name="RustDesk"
```

---

## 📝 一键安装脚本

将以下内容保存为 `Install_RustDesk_Service.ps1`：

```powershell
# ===============================================
# Install_RustDesk_Service.ps1
# 自动安装 RustDesk 为 Windows 服务
# ===============================================

# 检查管理员权限
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "❌ 需要管理员权限！请以管理员身份运行此脚本。"
    Pause
    Exit 1
}

Write-Host "=== RustDesk 服务安装工具 ===" -ForegroundColor Cyan
Write-Host ""

# RustDesk 路径
$RustDeskPath = "C:\Program Files\RustDesk\rustdesk.exe"

# 检查 RustDesk 是否已安装
if (-not (Test-Path $RustDeskPath)) {
    Write-Error "❌ 未找到 RustDesk！"
    Write-Host "请先安装 RustDesk: https://rustdesk.com/" -ForegroundColor Yellow
    Write-Host "默认安装路径应为: $RustDeskPath" -ForegroundColor Yellow
    Pause
    Exit 1
}

Write-Host "✓ 找到 RustDesk: $RustDeskPath" -ForegroundColor Green

# 步骤 1: 检查服务是否已存在
$existingService = Get-Service -Name "RustDesk" -ErrorAction SilentlyContinue
if ($existingService) {
    Write-Host "⚠️  RustDesk 服务已存在" -ForegroundColor Yellow
    $reinstall = Read-Host "是否重新安装? (y/N)"
    if ($reinstall -ne 'y' -and $reinstall -ne 'Y') {
        Write-Host "取消安装。" -ForegroundColor Gray
        Pause
        Exit 0
    }
    
    # 卸载现有服务
    Write-Host "正在卸载现有服务..." -ForegroundColor Yellow
    Stop-Service RustDesk -Force -ErrorAction SilentlyContinue
    & $RustDeskPath --uninstall-service
    Start-Sleep -Seconds 2
}

# 步骤 2: 安装服务
Write-Host ""
Write-Host "[1/4] 正在安装 RustDesk 服务..." -ForegroundColor Cyan
try {
    & $RustDeskPath --install-service
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
    Start-Sleep -Seconds 2
    $serviceStatus = Get-Service RustDesk
    if ($serviceStatus.Status -eq 'Running') {
        Write-Host "      ✓ 服务已成功启动" -ForegroundColor Green
    } else {
        Write-Warning "服务状态: $($serviceStatus.Status)"
    }
} catch {
    Write-Warning "启动服务失败: $($_.Exception.Message)"
}

# 步骤 5: 配置防火墙
Write-Host ""
Write-Host "[4/4] 正在配置防火墙..." -ForegroundColor Cyan
try {
    # 删除旧规则（如果存在）
    netsh advfirewall firewall delete rule name="RustDesk" 2>$null
    
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
Write-Host "服务信息:" -ForegroundColor Cyan
Get-Service RustDesk | Format-Table Name, Status, StartType, DisplayName -AutoSize

Write-Host ""
Write-Host "💡 提示:" -ForegroundColor Yellow
Write-Host "  • RustDesk 现在作为服务运行，即使用户注销也会保持运行" -ForegroundColor Gray
Write-Host "  • 可以通过 services.msc 管理服务" -ForegroundColor Gray
Write-Host "  • 连接 ID 和密码可在 RustDesk 客户端查看" -ForegroundColor Gray

Write-Host ""
Pause
```

**使用方法**：
```powershell
# 以管理员身份运行
.\Install_RustDesk_Service.ps1
```

---

## 🔄 服务管理命令

### 查看服务状态

```powershell
# 简单查看
Get-Service RustDesk

# 详细信息
Get-Service RustDesk | Format-List *

# 查看服务配置
sc.exe qc RustDesk
```

### 启动/停止/重启服务

```powershell
# 启动服务
Start-Service RustDesk

# 停止服务
Stop-Service RustDesk

# 重启服务
Restart-Service RustDesk

# 强制停止
Stop-Service RustDesk -Force
```

### 修改启动类型

```powershell
# 自动启动
Set-Service RustDesk -StartupType Automatic

# 手动启动
Set-Service RustDesk -StartupType Manual

# 禁用
Set-Service RustDesk -StartupType Disabled
```

### 查看服务日志

```powershell
# 查看 Windows 事件日志中的 RustDesk 相关事件
Get-EventLog -LogName Application -Source RustDesk -Newest 20
```

---

## 🗑️ 卸载 RustDesk 服务

### 方法 1: 使用 PowerShell

```powershell
# 以管理员身份运行
$RustDeskPath = "C:\Program Files\RustDesk\rustdesk.exe"

# 停止服务
Stop-Service RustDesk -Force -ErrorAction SilentlyContinue

# 卸载服务
& $RustDeskPath --uninstall-service

# 删除防火墙规则
netsh advfirewall firewall delete rule name="RustDesk"

Write-Host "✓ RustDesk 服务已卸载" -ForegroundColor Green
```

### 方法 2: 使用恢复脚本

```batch
cd "Restore PC"
POS_restore.bat
```

此脚本会自动移除 RustDesk 服务和所有相关配置。

---

## 🔍 故障排除

### 问题 1: 服务无法启动

**症状**：`Start-Service RustDesk` 失败

**解决方案**：

```powershell
# 检查 RustDesk 进程
Get-Process rustdesk -ErrorAction SilentlyContinue

# 如果进程已运行，先停止
Stop-Process -Name rustdesk -Force

# 重新启动服务
Start-Service RustDesk
```

### 问题 2: 无法连接

**可能原因**：
1. 防火墙阻止
2. 网络配置问题
3. RustDesk 服务未运行

**检查步骤**：

```powershell
# 1. 检查服务状态
Get-Service RustDesk

# 2. 检查防火墙规则
netsh advfirewall firewall show rule name="RustDesk"

# 3. 测试网络连接（如果使用自建服务器）
Test-NetConnection -ComputerName your-server.com -Port 21116
```

### 问题 3: 服务安装失败

**解决方案**：

```powershell
# 1. 确保以管理员身份运行
# 2. 检查 RustDesk 是否正确安装
Test-Path "C:\Program Files\RustDesk\rustdesk.exe"

# 3. 尝试重新安装 RustDesk 应用程序
# 4. 检查防病毒软件是否阻止
```

### 问题 4: 重启后服务未自动启动

**解决方案**：

```powershell
# 检查启动类型
Get-Service RustDesk | Select-Object Name, StartType

# 设置为自动启动
Set-Service RustDesk -StartupType Automatic

# 检查服务依赖
sc.exe qc RustDesk
```

---

## 📊 服务配置参数

### RustDesk 命令行参数

| 参数 | 说明 |
|------|------|
| `--install-service` | 安装为 Windows 服务 |
| `--uninstall-service` | 卸载服务 |
| `--service` | 以服务模式运行 |
| `--password <password>` | 设置永久密码 |
| `--config <file>` | 指定配置文件路径 |

**示例**：

```powershell
# 安装服务并设置密码
& "C:\Program Files\RustDesk\rustdesk.exe" --install-service --password "YourSecurePassword123"
```

---

## 🔐 安全建议

### 1. 设置强密码

```powershell
# 设置永久密码（重启后不变）
& "C:\Program Files\RustDesk\rustdesk.exe" --password "YourStrongPassword123!"
```

### 2. 使用自建服务器

在 RustDesk 设置中配置自己的中继服务器，避免使用公共服务器。

### 3. 定期更新

```powershell
# 检查当前版本
& "C:\Program Files\RustDesk\rustdesk.exe" --version

# 定期访问官网下载最新版本
# https://rustdesk.com/
```

### 4. 监控访问日志

定期检查 Windows 事件日志，监控远程访问活动。

### 5. 网络限制

通过防火墙规则限制只允许特定 IP 地址访问：

```powershell
# 删除现有规则
netsh advfirewall firewall delete rule name="RustDesk"

# 添加限制 IP 的规则
$AllowedIP = "192.168.1.100"  # 替换为您的 IP
netsh advfirewall firewall add rule name="RustDesk" dir=in action=allow program="C:\Program Files\RustDesk\rustdesk.exe" remoteip=$AllowedIP enable=yes
```

---

## 📚 相关资源

### 官方文档
- **官网**: https://rustdesk.com/
- **GitHub**: https://github.com/rustdesk/rustdesk
- **文档**: https://rustdesk.com/docs/

### 常用链接
- [下载页面](https://github.com/rustdesk/rustdesk/releases)
- [服务器搭建指南](https://rustdesk.com/docs/en/self-host/)
- [常见问题](https://github.com/rustdesk/rustdesk/wiki/FAQ)

---

## 🎯 最佳实践

1. **自动安装** - 使用 POS Setup 脚本自动配置（推荐）
2. **手动安装** - 使用上述 PowerShell 脚本进行精确控制
3. **定期维护** - 每月检查服务状态和更新
4. **备份配置** - 保存 RustDesk 的配置文件
5. **测试连接** - 安装后立即测试远程连接功能

---

## ✅ 快速检查清单

安装完成后，验证以下项目：

- [ ] RustDesk 服务状态为 "Running"
- [ ] 启动类型设置为 "Automatic"
- [ ] 防火墙规则已添加
- [ ] 可以从其他设备远程连接
- [ ] 连接 ID 和密码已记录
- [ ] 服务在重启后自动启动

---

**最后更新**: 2025-10-14  
**版本**: v1.0

**提示**: 建议将此文档保存以便快速参考！