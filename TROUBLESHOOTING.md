# 🔧 故障排除指南 - Troubleshooting Guide

## 常见问题及解决方案

### ⚠️ 问题 1: 运行 Setup 脚本后无法打开 Settings（设置）

#### 症状
- 点击"开始"菜单中的"设置"无响应
- 使用 `Win + I` 快捷键无法打开设置
- 控制面板也无法访问

#### 原因
POS Setup 脚本为了安全和防止用户误操作，禁用了 Windows 设置和控制面板的访问权限。
这是通过以下注册表项实现的：
```
HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoControlPanel = 1
```

#### 解决方案

##### 🔹 方法 1: 使用快速修复命令（推荐）

**以管理员身份运行 PowerShell**，然后执行以下命令：

```powershell
# 删除禁用设置的注册表项
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoControlPanel /f

# 删除设置页面可见性限制（如果存在）
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v SettingsPageVisibility /f

# 重启 Explorer 使更改生效
Stop-Process -Name explorer -Force
Start-Process explorer

Write-Host "✓ Settings 已重新启用！" -ForegroundColor Green
```

##### 🔹 方法 2: 使用一键修复脚本

创建并运行以下批处理文件 `Enable_Settings.bat`：

```batch
@echo off
echo ================================================
echo   重新启用 Windows Settings
echo ================================================
echo.

reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoControlPanel /f 2>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v SettingsPageVisibility /f 2>nul

echo.
echo ✓ Settings 已重新启用
echo ✓ 正在重启 Explorer...

taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo.
echo ✓ 完成！现在可以打开 Settings 了
echo.
pause
```

##### 🔹 方法 3: 使用注册表编辑器（手动方式）

1. 按 `Win + R` 打开运行对话框
2. 输入 `regedit` 并按回车
3. 导航到：
   ```
   HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer
   ```
4. 找到并删除 `NoControlPanel` 项
5. 同时检查：
   ```
   HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer
   ```
6. 如果存在 `SettingsPageVisibility` 项，也删除它
7. 重启 Explorer 或重启电脑

##### 🔹 方法 4: 运行完整恢复脚本

如果需要完全恢复系统设置：

```batch
cd "Restore PC"
POS_restore.bat
```

**注意**：这将恢复所有 POS 配置，而不仅仅是 Settings。

---

### ⚠️ 问题 2: 运行脚本后无法访问网络

#### 症状
- 无法访问外部网站
- 只能访问内网资源

#### 原因
脚本配置了严格的防火墙规则，默认阻止所有外部流量，只允许内网访问。

#### 解决方案

**临时允许外部访问**：

```powershell
# 以管理员身份运行
netsh advfirewall set allprofiles firewallpolicy blockinbound,allowoutbound
```

**完全重置防火墙**：

```powershell
netsh advfirewall reset
```

---

### ⚠️ 问题 3: Windows Update 服务无法启动

#### 症状
- 无法检查更新
- Windows Update 服务被禁用

#### 解决方案

```powershell
# 以管理员身份运行
Set-Service -Name wuauserv -StartupType Manual
Start-Service -Name wuauserv

# 删除更新策略限制
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f
```

---

### ⚠️ 问题 4: 自动登录不工作

#### 症状
- 重启后仍需要手动输入密码
- 自动登录配置似乎无效

#### 可能原因
1. 密码输入错误
2. 用户账户类型不正确
3. 组策略冲突

#### 解决方案

**重新配置自动登录**：

```powershell
# 以管理员身份运行
$UserName = "Beheer"
$Password = "你的密码"

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /t REG_SZ /d $UserName /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d $Password /f
```

**使用 Windows 内置工具**：

1. 按 `Win + R`
2. 输入 `netplwiz` 或 `control userpasswords2`
3. 取消勾选"要使用本计算机，用户必须输入用户名和密码"
4. 输入凭据并确认

---

### ⚠️ 问题 5: RustDesk 无法连接

#### 症状
- RustDesk 无法启动
- 远程连接失败

#### 解决方案

**检查服务状态**：

```powershell
Get-Service RustDesk
```

**重启服务**：

```powershell
Restart-Service RustDesk -Force
```

**检查防火墙规则**：

```powershell
netsh advfirewall firewall show rule name="RustDesk"
```

**重新添加防火墙规则**：

```powershell
$RustDeskPath = "C:\Program Files\RustDesk\rustdesk.exe"
netsh advfirewall firewall add rule name="RustDesk" dir=in action=allow program="$RustDeskPath" enable=yes
```

---

### ⚠️ 问题 6: POS 程序无法自动启动

#### 症状
- 重启后 POS 程序不会自动运行
- 需要手动启动 POS

#### 解决方案

**检查启动项**：

```powershell
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Select-Object POSApp
```

**重新添加启动项**：

```powershell
$POSPath = "C:\POS\startPOS.bat"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v POSApp /t REG_SZ /d $POSPath /f
```

**验证 POS 路径**：

```powershell
Test-Path "C:\POS\startPOS.bat"
```

---

### ⚠️ 问题 7: 某些服务被禁用后系统不稳定

#### 症状
- 系统运行缓慢
- 某些功能异常

#### 被禁用的服务列表
- DiagTrack (诊断跟踪)
- SysMain (内存优化)
- WSearch (Windows 搜索)
- OneSyncSvc (同步服务)
- XblGameSave (Xbox 游戏保存)
- WMPNetworkSvc (Windows Media Player 网络共享)

#### 解决方案

**恢复单个服务**：

```powershell
# 示例：恢复搜索服务
Set-Service -Name WSearch -StartupType Manual
Start-Service -Name WSearch
```

**恢复所有服务**：

```powershell
$services = @("DiagTrack", "SysMain", "WSearch", "OneSyncSvc", "XblGameSave", "WMPNetworkSvc")
foreach ($svc in $services) {
    Set-Service -Name $svc -StartupType Manual -ErrorAction SilentlyContinue
    Start-Service -Name $svc -ErrorAction SilentlyContinue
}
```

---

## 🛠️ 快速修复命令集合

### 重新启用 Settings（最常用）

```powershell
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoControlPanel /f
Stop-Process -Name explorer -Force ; Start-Process explorer
```

### 重置防火墙

```powershell
netsh advfirewall reset
```

### 恢复 Windows Update

```powershell
Set-Service -Name wuauserv -StartupType Manual
Start-Service -Name wuauserv
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f
```

### 完全恢复系统

```batch
cd "Restore PC"
POS_restore.bat
```

---

## 📞 获取帮助

### 日志位置
- 安装日志: `C:\POS\Logs\setup_*.log`
- 恢复日志: `C:\POS\Logs\restore_*.log`

### 备份位置
- 注册表备份: `C:\POS\Backup\registry_backup_*.reg`
- 服务状态备份: `C:\POS\Backup\services_backup_*.csv`

### 紧急恢复
如果系统无法正常启动：
1. 进入安全模式（按 F8 或 Shift + F8）
2. 运行恢复脚本或手动删除注册表项
3. 使用系统还原点恢复

---

## ⚡ 预防措施

### 使用前建议
1. 创建系统还原点
2. 备份重要数据
3. 在测试环境中验证
4. 记录当前配置

### 定期维护
1. 检查日志文件
2. 验证备份完整性
3. 测试恢复脚本
4. 更新文档

---

**最后更新**: 2025-10-14