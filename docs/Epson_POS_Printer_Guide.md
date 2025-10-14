# 🖨️ Epson POS 打印机安装指南

## 📋 目录

- [支持的型号](#支持的型号)
- [驱动下载](#驱动下载)
- [安装步骤](#安装步骤)
- [常见型号配置](#常见型号配置)
- [故障排除](#故障排除)
- [高级配置](#高级配置)

---

## 📦 支持的型号

### TM-T20 系列（最常用）

| 型号 | 发布年份 | 接口 | 状态 | 推荐驱动 |
|------|---------|------|------|---------|
| **TM-T20** | 2009 | USB, 串口, 以太网 | ✅ 稳定 | APD6 |
| **TM-T20II** | 2013 | USB, 串口, 以太网 | ✅ 稳定 | APD6 |
| **TM-T20III** | 2018 | USB, 串口, 以太网 | ✅ 推荐 | APD6 |
| **TM-T20X** | 2021 | USB, 串口, 以太网, 蓝牙 | ✅ 最新 | APD6 |

### TM-M30 系列（新一代）

| 型号 | 发布年份 | 接口 | 特点 | 推荐驱动 |
|------|---------|------|------|---------|
| **TM-M30** | 2016 | USB, 以太网 | 方形设计，静音 | APD6 |
| **TM-M30II** | 2020 | USB, 以太网, 蓝牙 | 改进版，更快 | APD6 |
| **TM-M30III** | 2023 | USB, 以太网, 蓝牙, Wi-Fi | 最新款，支持云打印 | APD6 |

### 其他常见型号

| 型号 | 接口 | 适用场景 | 推荐驱动 |
|------|------|---------|---------|
| **TM-T82** | USB, 串口, 以太网 | 厨房打印机 | APD6 |
| **TM-T88V** | USB, 串口, 以太网 | 高速收据打印 | APD6 |
| **TM-T88VI** | USB, 以太网 | 最新高速型号 | APD6 |
| **TM-U220** | USB, 串口 | 针式打印机（多联单） | APD5 |

---

## 💾 驱动下载

### 推荐驱动：Epson Advanced Printer Driver (APD6)

**官方下载地址**：
- 英文站：https://epson.com/Support/Point-of-Sale/
- 中文站：https://www.epson.com.cn/apps/tech_support/support/

**驱动包类型**：

1. **APD6 (Advanced Printer Driver 6)** - 推荐
   - 支持所有现代 Epson POS 打印机
   - Windows 11/10/8.1/7 兼容
   - 统一驱动，一次安装支持多型号

2. **OPOS (OLE for Point of Service)** - 专业 POS 系统
   - 适用于需要 OPOS 标准的 POS 软件
   - 更底层的控制

3. **JavaPOS** - Java 应用程序
   - 适用于 Java 开发的 POS 系统

### 快速下载（荷兰站点）

```
Epson 荷兰官网：
https://www.epson.nl/support

搜索型号示例：
- TM-T20II
- TM-M30
- TM-T88VI
```

---

## 🔧 安装步骤

### 方法 1: USB 连接（最简单）

#### Step 1: 下载并安装驱动

```batch
# 1. 下载 APD6 驱动安装包
# 2. 解压到本地文件夹
# 3. 以管理员身份运行安装程序
```

#### Step 2: 连接打印机

```
1. 连接 USB 线到打印机和电脑
2. 打开打印机电源
3. Windows 会自动检测设备
4. 等待驱动安装完成
```

#### Step 3: 验证安装

```powershell
# 查看已安装的打印机
Get-Printer

# 应该看到类似：
# Name: EPSON TM-T20II Receipt
# Status: Normal
```

---

### 方法 2: 网络连接（以太网）

#### Step 1: 配置打印机 IP 地址

**使用打印机按钮配置**：
```
1. 关闭打印机
2. 按住 FEED 按钮不放
3. 打开电源，继续按住 FEED 3-5 秒
4. 释放按钮，打印机会打印网络配置单
5. 记录当前 IP 地址
```

**或使用 Epson 网络工具**：
```
1. 下载 EpsonNet Config（随驱动提供）
2. 运行工具，搜索网络中的打印机
3. 设置 IP 地址（推荐静态 IP）
```

#### Step 2: 添加网络打印机

**PowerShell 方法**：

```powershell
# 设置变量
$PrinterIP = "192.168.1.100"  # 打印机 IP 地址
$PrinterName = "Epson TM-T20II Receipt"
$DriverName = "EPSON TM-T20II Receipt"  # 必须先安装 APD6 驱动

# 添加打印机端口
Add-PrinterPort -Name "IP_$PrinterIP" -PrinterHostAddress $PrinterIP

# 添加打印机
Add-Printer -Name $PrinterName -DriverName $DriverName -PortName "IP_$PrinterIP"

# 设置为默认打印机（可选）
Set-Printer -Name $PrinterName -Default

Write-Host "✓ 打印机添加成功：$PrinterName" -ForegroundColor Green
```

**UI 方法**：
```
1. Win + R → control printers
2. 添加打印机 → 我需要的打印机不在列表中
3. 选择：使用 TCP/IP 地址或主机名添加打印机
4. 输入 IP 地址：192.168.1.100
5. 选择驱动：EPSON TM-T20II Receipt (APD6)
6. 完成
```

---

## 🎯 常见型号配置

### TM-T20II 配置（最常用）

```powershell
# 完整配置脚本
$PrinterIP = "192.168.1.100"
$PrinterName = "POS Receipt Printer"
$DriverName = "EPSON TM-T20II Receipt"

# 添加端口
Add-PrinterPort -Name "IP_$PrinterIP" -PrinterHostAddress $PrinterIP

# 添加打印机
Add-Printer -Name $PrinterName -DriverName $DriverName -PortName "IP_$PrinterIP"

# 配置打印机属性
Set-PrintConfiguration -PrinterName $PrinterName -PaperSize "Roll Paper 80 x 297 mm"

# 设置为共享（如果需要）
Set-Printer -Name $PrinterName -Shared $true -ShareName "POSPrinter"

Write-Host "✓ TM-T20II 配置完成" -ForegroundColor Green
```

**打印测试页**：
```powershell
# 方法 1: PowerShell
$printer = Get-Printer -Name "POS Receipt Printer"
Invoke-Command {notepad /p test.txt} -ArgumentList $printer

# 方法 2: 打印机自检
# 按住 FEED 按钮，打开电源，释放按钮
```

---

### TM-M30II 配置（新型号）

```powershell
$PrinterIP = "192.168.1.101"
$PrinterName = "POS M30 Printer"
$DriverName = "EPSON TM-M30II"

# 添加端口
Add-PrinterPort -Name "IP_$PrinterIP" -PrinterHostAddress $PrinterIP

# 添加打印机
Add-Printer -Name $PrinterName -DriverName $DriverName -PortName "IP_$PrinterIP"

# M30 系列特殊配置
Set-PrintConfiguration -PrinterName $PrinterName -PaperSize "Roll Paper 80 x 297 mm"

Write-Host "✓ TM-M30II 配置完成" -ForegroundColor Green
```

---

### TM-T88VI 配置（高速型号）

```powershell
$PrinterIP = "192.168.1.102"
$PrinterName = "POS T88VI Printer"
$DriverName = "EPSON TM-T88VI"

# 添加端口
Add-PrinterPort -Name "IP_$PrinterIP" -PrinterHostAddress $PrinterIP

# 添加打印机
Add-Printer -Name $PrinterName -DriverName $DriverName -PortName "IP_$PrinterIP"

# T88VI 高速配置
Set-PrintConfiguration -PrinterName $PrinterName -PaperSize "Roll Paper 80 x 297 mm"

Write-Host "✓ TM-T88VI 配置完成" -ForegroundColor Green
```

---

## ⚠️ 故障排除

### 问题 1: 找不到驱动程序

**解决方案**：

```powershell
# 检查已安装的驱动
Get-PrinterDriver | Where-Object {$_.Name -like "*EPSON*"}

# 如果没有，需要手动安装 APD6 驱动
# 1. 下载 APD6 安装包
# 2. 解压并运行安装程序
# 3. 重新添加打印机
```

---

### 问题 2: 打印机离线

**诊断步骤**：

```powershell
# 1. 检查打印机状态
Get-Printer -Name "POS Receipt Printer" | Select-Object Name, PrinterStatus, JobCount

# 2. 测试网络连接（网络打印机）
Test-NetConnection -ComputerName 192.168.1.100 -Port 9100

# 3. 重启打印后台服务
Restart-Service Spooler

# 4. 清除打印队列
Stop-Service Spooler
Remove-Item -Path "C:\Windows\System32\spool\PRINTERS\*" -Force
Start-Service Spooler

# 5. 重新上线打印机
Set-Printer -Name "POS Receipt Printer" -PrinterStatus Normal
```

---

### 问题 3: 打印内容错误或乱码

**解决方案**：

```powershell
# 检查驱动是否正确
Get-Printer -Name "POS Receipt Printer" | Select-Object DriverName

# 正确的驱动名称应该是：
# - EPSON TM-T20II Receipt (APD6)
# - EPSON TM-M30II
# - EPSON TM-T88VI

# 如果不对，删除并重新添加
Remove-Printer -Name "POS Receipt Printer"
# 重新添加（使用正确的驱动名称）
```

**检查纸张设置**：
```powershell
# 查看纸张配置
Get-PrintConfiguration -PrinterName "POS Receipt Printer"

# 标准 80mm 收据纸设置
Set-PrintConfiguration -PrinterName "POS Receipt Printer" -PaperSize "Roll Paper 80 x 297 mm"
```

---

### 问题 4: 无法通过网络访问打印机

**诊断和修复**：

```powershell
# 1. Ping 打印机
ping 192.168.1.100

# 2. 测试打印机端口（通常是 9100）
Test-NetConnection -ComputerName 192.168.1.100 -Port 9100

# 3. 检查防火墙
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*File and Printer*"}

# 4. 启用文件和打印机共享
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes

# 5. 重置打印机 IP（如果需要）
# 使用 EpsonNet Config 工具
```

---

### 问题 5: USB 打印机无法识别

**解决方案**：

```powershell
# 1. 检查 USB 设备
Get-PnpDevice | Where-Object {$_.FriendlyName -like "*EPSON*"}

# 2. 查看设备管理器
devmgmt.msc

# 3. 如果显示黄色感叹号
# - 右键设备 → 更新驱动程序
# - 手动选择 APD6 驱动位置

# 4. 尝试不同的 USB 端口
# - 建议使用 USB 2.0 端口（更兼容）

# 5. 重新安装 USB 驱动
# - 卸载设备
# - 拔掉 USB 线
# - 重启电脑
# - 重新插入 USB 线
```

---

## 🔬 高级配置

### 配置切刀（Auto Cutter）

```powershell
# TM-T20II 切刀设置（通过打印机属性）
# 1. 控制面板 → 设备和打印机
# 2. 右键打印机 → 打印首选项
# 3. 高级 → 切刀 → 选择模式：
#    - "Feed and cut" - 打印后切纸
#    - "No cut" - 不切纸
#    - "Feed, cut and feed" - 切纸后进纸
```

### 配置蜂鸣器

```powershell
# 通过打印首选项配置
# 1. 右键打印机 → 打印首选项
# 2. 高级 → 蜂鸣器设置
# 3. 选择：开/关
```

### 配置钱箱（Cash Drawer）

```powershell
# 钱箱连接到打印机的 DK 端口
# 在打印首选项中配置：
# 1. 右键打印机 → 打印首选项
# 2. 高级 → Cash Drawer
# 3. 选择：Drawer #1 或 Drawer #2
# 4. 设置开启脉冲时间
```

### OPOS 配置（专业 POS 系统）

如果 POS 软件需要 OPOS：

```
1. 下载并安装 OPOS ADK (Application Development Kit)
2. 运行 SetupPOS.exe（在 OPOS 安装目录）
3. 添加逻辑设备名称
4. 配置设备参数：
   - Device Name: POSPrinter1
   - Port: COM1 或 IP_192.168.1.100
   - Device Type: Printer
5. 测试设备连接
```

---

## 📝 快速命令参考

### 常用 PowerShell 命令

```powershell
# 查看所有打印机
Get-Printer

# 查看特定打印机详情
Get-Printer -Name "POS Receipt Printer" | Format-List *

# 查看打印机驱动
Get-PrinterDriver

# 测试打印
$printer = Get-Printer -Name "POS Receipt Printer"
# 然后使用应用程序打印测试

# 设置默认打印机
Set-Printer -Name "POS Receipt Printer" -Default

# 查看打印队列
Get-PrintJob -PrinterName "POS Receipt Printer"

# 清除打印队列
Get-PrintJob -PrinterName "POS Receipt Printer" | Remove-PrintJob

# 重启打印服务
Restart-Service Spooler
```

---

## 📞 技术支持

### Epson 官方支持

- **全球支持**: https://epson.com/Support
- **荷兰支持**: https://www.epson.nl/support
- **技术热线**: 查看官网各地区联系方式

### 实用工具

| 工具 | 用途 | 下载位置 |
|------|------|---------|
| **EpsonNet Config** | 网络打印机配置 | Epson 官网 |
| **TM Utility** | 打印机诊断和设置 | Epson 官网 |
| **ePOS Print SDK** | 开发者工具 | Epson 开发者网站 |

---

## ✅ 安装检查清单

- [ ] 下载并安装 APD6 驱动
- [ ] 连接打印机（USB 或网络）
- [ ] 配置 IP 地址（网络打印机）
- [ ] 添加打印机到 Windows
- [ ] 设置纸张大小（80mm）
- [ ] 打印测试页
- [ ] 配置切刀（如需要）
- [ ] 配置钱箱（如需要）
- [ ] 设置为默认打印机（如需要）
- [ ] 配置打印机共享（多台电脑）

---

**最后更新**: 2025-10-14  
**版本**: v1.0  
**支持**: Windows 11/10/8.1

💡 **提示**: 建议为每个 POS 终端配置静态 IP 地址的网络打印机，方便管理和故障排除！
