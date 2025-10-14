# 🚀 POS 系统快速参考手册

## 📑 目录快速跳转

- [🔧 Windows 系统常用命令](#-windows-系统常用命令)
- [🌐 网络配置](#-网络配置)
- [🖨️ 打印机配置](#-打印机配置)
- [🌍 语言和区域设置](#-语言和区域设置)
- [⚙️ 系统管理工具](#️-系统管理工具)
- [🔥 防火墙配置](#-防火墙配置)
- [🖥️ RustDesk 远程管理](#️-rustdesk-远程管理)
- [⚠️ 常见问题快速修复](#️-常见问题快速修复)
- [📋 POS Setup 相关](#-pos-setup-相关)
- [🔍 快速查找指南](#-快速查找指南)
- [📞 需要帮助](#-需要帮助)

---

## 🔧 Windows 系统常用命令

### 系统配置工具

| 命令 | 功能 | 说明 |
|------|------|------|
| `Win + R` → `ncpa.cpl` | **网络连接** | **配置网卡、IP地址（最常用）** |
| `Win + R` → `netplwiz` | 用户账户管理 | 配置自动登录、管理用户 |
| `Win + R` → `services.msc` | 服务管理 | 启动/停止/配置系统服务 |
| `Win + R` → `msconfig` | 系统配置 | 启动项、服务、引导设置 |
| `Win + R` → `regedit` | 注册表编辑器 | 高级系统配置 |
| `Win + R` → `taskmgr` | 任务管理器 | 进程管理、性能监控 |
| `Win + R` → `devmgmt.msc` | 设备管理器 | 硬件设备管理 |
| `Win + R` → `compmgmt.msc` | 计算机管理 | 综合管理控制台 |
| `Win + R` → `control printers` | 打印机和扫描仪 | 管理打印机设备 |
| `Win + R` → `intl.cpl` | 区域设置 | 语言、时间格式设置 |
| `Win + R` → `firewall.cpl` | 防火墙设置 | Windows 防火墙配置 |
| `Win + R` → `control` | 控制面板 | 传统设置界面 |
| `Win + I` | Windows 设置 | 现代设置界面 |
| `Win + X` | 快速访问菜单 | 系统工具快捷菜单 |

### 快速启动命令

```batch
# 以管理员身份打开 PowerShell
Win + X → A

# 打开运行对话框
Win + R

# 打开任务管理器
Ctrl + Shift + Esc
```

---

## 🌐 网络配置

### 查看网络信息

```powershell
# 查看所有网卡信息
Get-NetAdapter

# 查看 IP 配置
Get-NetIPConfiguration

# 查看详细 IP 信息
ipconfig /all

# 查看 DNS 设置
Get-DnsClientServerAddress
```

### 配置静态 IP

```powershell
# 设置静态 IP（替换实际值）
$InterfaceIndex = (Get-NetAdapter -Name "以太网").ifIndex
New-NetIPAddress -InterfaceIndex $InterfaceIndex -IPAddress "192.168.1.100" -PrefixLength 24 -DefaultGateway "192.168.1.1"
Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex -ServerAddresses ("8.8.8.8","8.8.4.4")

# 或使用网卡名称
New-NetIPAddress -InterfaceAlias "以太网" -IPAddress "192.168.1.100" -PrefixLength 24 -DefaultGateway "192.168.1.1"
Set-DnsClientServerAddress -InterfaceAlias "以太网" -ServerAddresses "8.8.8.8","8.8.4.4"
```

### 配置 DHCP（自动获取）

```powershell
# 设置为 DHCP
Set-NetIPInterface -InterfaceAlias "以太网" -Dhcp Enabled
Set-DnsClientServerAddress -InterfaceAlias "以太网" -ResetServerAddresses
```

### 🔥 网络配置文件（公用/专用）- 重要！

**影响范围**：网络发现、文件共享、打印机共享

```powershell
# 查看当前网络配置文件类型
Get-NetConnectionProfile

# 设置为专用网络（推荐用于内网/办公室）
Set-NetConnectionProfile -InterfaceAlias "以太网" -NetworkCategory Private

# 设置为公用网络（用于公共场所，限制共享）
Set-NetConnectionProfile -InterfaceAlias "以太网" -NetworkCategory Public

# 或使用 InterfaceIndex
$InterfaceIndex = (Get-NetAdapter -Name "以太网").ifIndex
Set-NetConnectionProfile -InterfaceIndex $InterfaceIndex -NetworkCategory Private
```

**网络类型说明**：

| 类型 | 适用场景 | 网络发现 | 文件共享 | 安全级别 |
|------|---------|---------|---------|---------|
| **Private（专用）** | 内网、办公室、家庭 | ✅ 启用 | ✅ 可用 | 中 |
| **Public（公用）** | 咖啡厅、机场、酒店 | ❌ 禁用 | ❌ 禁用 | 高 |
| **Domain（域）** | 企业域环境 | ✅ 启用 | ✅ 可用 | 由策略控制 |

**快速设置（使用 UI）**：
```batch
# 方法 1: 设置应用
Win + I → 网络和 Internet → 以太网 → 网络配置文件类型

# 方法 2: 网络和共享中心
Win + R → control.exe /name Microsoft.NetworkAndSharingCenter
# 点击当前网络 → 选择"专用"或"公用"
```

**POS 系统推荐配置**：
- ✅ 设置为 **专用网络**（内网环境）
- ✅ 启用网络发现和文件共享
- ✅ 允许打印机和设备共享

### 网络诊断

```powershell
# 测试网络连接
Test-NetConnection -ComputerName google.com
Test-NetConnection -ComputerName 192.168.1.1 -Port 80

# Ping 测试
ping 192.168.1.1

# 路由追踪
tracert google.com

# 查看路由表
route print

# 刷新 DNS 缓存
ipconfig /flushdns

# 重置网络配置
netsh winsock reset
netsh int ip reset
```

### 🔥 网络共享和发现（内网必备）

**一键启用网络发现和文件共享**：

```powershell
# 1. 设置网络为专用
Set-NetConnectionProfile -NetworkCategory Private

# 2. 启用网络发现（允许看到其他设备）
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes

# 3. 启用文件和打印机共享
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes

# 4. 启用 SMB 文件共享服务
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force  # 禁用不安全的SMB1
Set-SmbServerConfiguration -EnableSMB2Protocol $true -Force    # 启用SMB2/3
```

**验证配置**：

```powershell
# 查看当前网络类型
Get-NetConnectionProfile

# 查看防火墙规则
Get-NetFirewallRule -DisplayGroup "Network Discovery" | Where-Object {$_.Enabled -eq 'True'}
Get-NetFirewallRule -DisplayGroup "File and Printer Sharing" | Where-Object {$_.Enabled -eq 'True'}

# 查看 SMB 配置
Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol, EnableSMB2Protocol
```

**完整配置脚本（内网共享）**：

```powershell
# 内网完整配置脚本
$InterfaceAlias = "以太网"  # 根据实际网卡名称修改

Write-Host "配置内网共享..." -ForegroundColor Green

# 1. 设置专用网络
Set-NetConnectionProfile -InterfaceAlias $InterfaceAlias -NetworkCategory Private
Write-Host "✓ 网络类型已设置为：专用" -ForegroundColor Green

# 2. 启用网络发现
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes
Write-Host "✓ 网络发现已启用" -ForegroundColor Green

# 3. 启用文件和打印机共享
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes
Write-Host "✓ 文件和打印机共享已启用" -ForegroundColor Green

# 4. 启用 SMB 服务
Enable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart -WarningAction SilentlyContinue | Out-Null
Set-SmbServerConfiguration -EnableSMB2Protocol $true -Force
Write-Host "✓ SMB 文件共享已启用" -ForegroundColor Green

Write-Host "`n✅ 内网共享配置完成！" -ForegroundColor Green
Write-Host "现在可以：" -ForegroundColor Yellow
Write-Host "  - 在文件资源管理器中看到其他设备" -ForegroundColor Yellow
Write-Host "  - 访问共享文件夹：\\computername\share" -ForegroundColor Yellow
Write-Host "  - 使用网络打印机" -ForegroundColor Yellow
```

**故障排除**：

```powershell
# 如果无法发现其他设备
# 检查服务状态
Get-Service -Name "FDResPub" | Start-Service  # 函数发现资源发布
Get-Service -Name "SSDPSRV" | Start-Service  # SSDP 发现
Get-Service -Name "upnphost" | Start-Service # UPnP 设备主机

# 重启网络发现
Restart-Service FDResPub, SSDPSRV, upnphost
```

---

## 🖨️ 打印机配置

### 打印机管理命令

```powershell
# 查看已安装的打印机
Get-Printer

# 查看打印机详细信息
Get-Printer | Format-List *

# 查看打印机端口
Get-PrinterPort

# 查看打印机驱动
Get-PrinterDriver
```

### 添加网络打印机

```powershell
# 方法 1: 使用 IP 地址添加（推荐）
$PrinterIP = "192.168.1.100"
$PrinterName = "Office Printer"
$DriverName = "Generic / Text Only"  # 或实际驱动名称

# 添加端口
Add-PrinterPort -Name "IP_$PrinterIP" -PrinterHostAddress $PrinterIP

# 添加打印机
Add-Printer -Name $PrinterName -DriverName $DriverName -PortName "IP_$PrinterIP"

# 方法 2: 使用 UI 添加
control printers
# 或
Win + R → control printers
```

### 设置默认打印机

```powershell
# 设置默认打印机
Set-Printer -Name "Office Printer" -Default

# 或使用 UI
# 设置 → 设备 → 打印机和扫描仪
```

### 打印机故障排除

```powershell
# 重启打印后台服务
Restart-Service Spooler

# 清除打印队列
Stop-Service Spooler
Remove-Item -Path "C:\Windows\System32\spool\PRINTERS\*" -Force
Start-Service Spooler

# 查看打印作业
Get-PrintJob -PrinterName "Office Printer"

# 删除所有打印作业
Get-PrintJob -PrinterName "Office Printer" | Remove-PrintJob
```

### 打印机共享

```powershell
# 共享打印机
Set-Printer -Name "Office Printer" -Shared $true -ShareName "OfficePrinter"

# 取消共享
Set-Printer -Name "Office Printer" -Shared $false
```

---

## 🌍 语言和区域设置

### 系统语言设置

```powershell
# 查看当前系统语言
Get-WinSystemLocale

# 设置系统区域为荷兰（Netherlands）
Set-WinSystemLocale -SystemLocale nl-NL

# 设置为美国英语
Set-WinSystemLocale -SystemLocale en-US

# 设置为中文
Set-WinSystemLocale -SystemLocale zh-CN
```

### 用户语言设置

```powershell
# 查看当前用户语言
Get-WinUserLanguageList

# 添加荷兰语
$LangList = Get-WinUserLanguageList
$LangList.Add("nl-NL")
Set-WinUserLanguageList $LangList -Force

# 设置首选语言
$LangList = Get-WinUserLanguageList
$LangList[0].LanguageTag = "nl-NL"
Set-WinUserLanguageList $LangList -Force
```

### 时区设置

```powershell
# 查看当前时区
Get-TimeZone

# 查看所有可用时区
Get-TimeZone -ListAvailable

# 设置时区为阿姆斯特丹（荷兰）
Set-TimeZone -Id "W. Europe Standard Time"

# 设置为中国标准时间
Set-TimeZone -Id "China Standard Time"

# 常用时区 ID
# "W. Europe Standard Time"  - 阿姆斯特丹、柏林、巴黎
# "China Standard Time"      - 北京
# "Eastern Standard Time"    - 纽约
# "Pacific Standard Time"    - 洛杉矶
```

### 日期和时间格式

```powershell
# 查看当前区域格式
Get-Culture

# 设置区域格式
Set-Culture -CultureInfo nl-NL

# 使用 UI 设置
Win + R → intl.cpl
```

### 键盘布局

```powershell
# 查看键盘布局
Get-WinUserLanguageList | Select-Object InputMethodTips

# 使用 UI 更改
# 设置 → 时间和语言 → 语言 → 首选语言 → 选项 → 键盘
```

---

## ⚙️ 系统管理工具

### 常用管理控制台

| 命令 | 控制台 | 用途 |
|------|--------|------|
| `services.msc` | 服务 | 管理系统服务 |
| `compmgmt.msc` | 计算机管理 | 综合管理 |
| `devmgmt.msc` | 设备管理器 | 硬件管理 |
| `diskmgmt.msc` | 磁盘管理 | 分区管理 |
| `eventvwr.msc` | 事件查看器 | 系统日志 |
| `taskschd.msc` | 任务计划程序 | 计划任务 |
| `perfmon.msc` | 性能监视器 | 性能分析 |
| `lusrmgr.msc` | 本地用户和组 | 用户管理 |
| `gpedit.msc` | 组策略编辑器 | 策略配置（专业版） |
| `secpol.msc` | 本地安全策略 | 安全设置 |

### 系统信息和诊断

```powershell
# 查看系统信息
systeminfo

# 查看 Windows 版本
winver

# 查看详细系统信息
Get-ComputerInfo

# 查看硬件信息
Get-WmiObject Win32_ComputerSystem

# 查看 BIOS 信息
Get-WmiObject Win32_BIOS

# 查看磁盘信息
Get-Disk
Get-Volume

# 查看已安装软件
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*
```

### 用户管理

```powershell
# 查看本地用户
Get-LocalUser

# 创建新用户
New-LocalUser -Name "POSUser" -Password (ConvertTo-SecureString "Password123!" -AsPlainText -Force) -FullName "POS User"

# 添加到管理员组
Add-LocalGroupMember -Group "Administrators" -Member "POSUser"

# 启用/禁用用户
Enable-LocalUser -Name "POSUser"
Disable-LocalUser -Name "POSUser"

# 使用 UI
netplwiz
```

### 远程桌面配置

```powershell
# 启用远程桌面
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# 禁用远程桌面
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 1

# 使用 UI
systempropertiesremote
```

---

## 🔥 防火墙配置

### 防火墙基本命令

```powershell
# 查看防火墙状态
Get-NetFirewallProfile

# 启用防火墙
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# 禁用防火墙（不推荐）
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# 查看防火墙规则
Get-NetFirewallRule | Where-Object {$_.Enabled -eq 'True'}

# 使用传统界面
firewall.cpl
# 或高级界面
wf.msc
```

### 添加防火墙规则

```powershell
# 允许特定程序
New-NetFirewallRule -DisplayName "POS Application" -Direction Inbound -Program "C:\POS\app.exe" -Action Allow

# 允许特定端口
New-NetFirewallRule -DisplayName "HTTP" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow

# 允许特定 IP 地址
New-NetFirewallRule -DisplayName "Allow Internal" -Direction Inbound -RemoteAddress 192.168.1.0/24 -Action Allow

# 删除规则
Remove-NetFirewallRule -DisplayName "POS Application"
```

### 内网访问配置（POS 常用）

```powershell
# 允许内网完全访问，阻止外网
netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound

# 允许内网地址段
$InternalNetworks = @("192.168.0.0/16", "10.0.0.0/8", "172.16.0.0/12")
foreach ($net in $InternalNetworks) {
    netsh advfirewall firewall add rule name="Allow Internal $net" dir=in action=allow remoteip=$net
    netsh advfirewall firewall add rule name="Allow Internal Out $net" dir=out action=allow remoteip=$net
}

# 允许本机回环
netsh advfirewall firewall add rule name="Loopback" dir=in action=allow localip=127.0.0.1 remoteip=127.0.0.1
```

---

## 🖥️ RustDesk 远程管理

### 快速安装

```batch
# 一键安装 RustDesk 服务
Install_RustDesk_Service.bat
```

### 常用命令

```powershell
# 查看服务状态
Get-Service RustDesk

# 启动服务
Start-Service RustDesk

# 停止服务
Stop-Service RustDesk

# 重启服务
Restart-Service RustDesk

# 设置永久密码
& "C:\Program Files\RustDesk\rustdesk.exe" --password "YourPassword123"

# 查看版本
& "C:\Program Files\RustDesk\rustdesk.exe" --version
```

### 手动安装为服务

```powershell
$RustDeskPath = "C:\Program Files\RustDesk\rustdesk.exe"
& $RustDeskPath --install-service
Set-Service RustDesk -StartupType Automatic
Start-Service RustDesk
netsh advfirewall firewall add rule name="RustDesk" dir=in action=allow program="$RustDeskPath" enable=yes
```

---

## ⚠️ 常见问题快速修复

### Settings 无法打开

```batch
# 一键修复
Enable_Settings.bat
```

```powershell
# 手动修复
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoControlPanel /f
Stop-Process -Name explorer -Force
Start-Process explorer
```

### 网络连接问题

```powershell
# 重置网络
netsh winsock reset
netsh int ip reset
ipconfig /release
ipconfig /renew
ipconfig /flushdns

# 重启网络适配器
Restart-NetAdapter -Name "以太网"
```

### 打印机不工作

```powershell
# 重启打印服务
Restart-Service Spooler

# 清除打印队列
Stop-Service Spooler
Remove-Item -Path "C:\Windows\System32\spool\PRINTERS\*" -Force
Start-Service Spooler
```

**Epson POS 打印机专项**：
- 📖 查看详细指南：`docs\Epson_POS_Printer_Guide.md`
- 🛠️ 快速安装工具：`Install_Epson_Printer.bat`
- 支持型号：TM-T20/T20II/T20III, TM-M30/M30II, TM-T88V/T88VI

### Windows Update 无法更新

```powershell
# 启动 Windows Update 服务
Set-Service -Name wuauserv -StartupType Manual
Start-Service -Name wuauserv

# 删除更新限制
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f
```

### 磁盘空间不足

```powershell
# 清理临时文件
cleanmgr

# 查看磁盘使用情况
Get-Volume

# 查找大文件
Get-ChildItem C:\ -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.Length -gt 100MB} | Sort-Object Length -Descending | Select-Object FullName, @{Name="Size(MB)";Expression={[math]::Round($_.Length/1MB,2)}}
```

---

## 📋 POS Setup 相关

### 主要脚本

```batch
# 完整 POS 配置
cd "New POS Setup"
POS_Setup.bat

# 恢复默认设置
cd "Restore PC"
POS_restore.bat

# 重新启用 Settings
Enable_Settings.bat

# 安装 RustDesk 服务
Install_RustDesk_Service.bat

# 设置密码（安全）
Set_POS_Password.bat
```

### 查看日志和备份

```powershell
# 查看安装日志
notepad "C:\POS\Logs\setup_*.log"

# 查看恢复日志
notepad "C:\POS\Logs\restore_*.log"

# 查看备份
explorer "C:\POS\Backup"
```

### 服务管理

```powershell
# 查看被禁用的服务
Get-Service | Where-Object {$_.StartType -eq 'Disabled'}

# 恢复特定服务
Set-Service -Name "WSearch" -StartupType Manual
Start-Service -Name "WSearch"
```

---

## 🔍 快速查找指南

### 按场景查找

| 场景 | 快速命令/脚本 | 说明 |
|------|--------------|------|
| **配置网卡 IP** | `Win + R` → `ncpa.cpl` | 🔥 **最常用！** 打开网络连接 |
| **网络设为专用** | `Set-NetConnectionProfile -NetworkCategory Private` | 🔥 **内网必备！** 启用共享 |
| **启用文件共享** | 见"网络共享和发现"章节 | 完整配置脚本 |
| **安装 Epson 打印机** | `Install_Epson_Printer.bat` | 🖨️ 支持 TM-T20/M30/T88 系列 |
| **添加打印机** | `Win + R` → `control printers` | 打印机管理 |
| **用户自动登录** | `Win + R` → `netplwiz` | 配置自动登录 |
| **管理服务** | `Win + R` → `services.msc` | 启动/停止服务 |
| **Settings 打不开** | `Enable_Settings.bat` | 一键修复脚本 |
| **需要远程访问** | `Install_RustDesk_Service.bat` | 安装远程管理 |
| **更改语言** | `Win + R` → `intl.cpl` | 区域和语言设置 |
| **防火墙配置** | `Win + R` → `firewall.cpl` | 基础防火墙设置 |
| **高级防火墙** | `Win + R` → `wf.msc` | 高级安全设置 |
| **网络诊断** | `ncpa.cpl` → 右键 → 诊断 | 自动修复网络问题 |
| **系统信息** | `Win + R` → `msinfo32` | 查看硬件和系统信息 |

### 常用快捷键

| 快捷键 | 功能 |
|--------|------|
| `Win + R` | 运行 |
| `Win + I` | 设置 |
| `Win + X` | 快速访问菜单 |
| `Win + E` | 文件资源管理器 |
| `Ctrl + Shift + Esc` | 任务管理器 |
| `Win + Pause` | 系统属性 |
| `Win + L` | 锁定计算机 |

---

## 📞 需要帮助？

### 详细文档

- **完整功能说明**: `README.md`
- **安全配置指南**: 查看 `docs/` 目录
- **RustDesk 详细指南**: 查看 `docs/` 目录

### 支持

- 检查日志: `C:\POS\Logs\`
- 查看备份: `C:\POS\Backup\`
- GitHub 仓库: https://github.com/CislinkNL/POS-Setup-Tools

---

**最后更新**: 2025-10-14  
**版本**: v3.0  
**用于**: POS 系统日常运维

💡 **提示**: 建议打印此文档或添加到浏览器收藏夹，以便现场快速查阅！