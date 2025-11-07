# 🖥️ POS Setup Tools

专业的 Windows 11 POS 系统配置和管理工具套件

[![License](https://img.shields.io/badge/license-Private-red.svg)]()
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)]()
[![Windows](https://img.shields.io/badge/Windows-11-0078D6.svg)]()

---

## 🚀 现场工作人员快速入口

### 📖 **[查看快速参考手册 (QUICK_REFERENCE.md)](./QUICK_REFERENCE.md)**

所有常用命令、网络配置、打印机设置、故障修复的**一站式解决方案**

### 📚 **[查看文档索引 (INDEX.md)](./INDEX.md)**

按场景快速查找所需文档和命令

---

## 📋 概述

这是一套用于快速配置和管理 Windows 11 POS 系统的专业脚本工具。包含系统优化、安全配置、网络设置、远程管理等功能，并提供完整的恢复机制。

### ✨ 主要特性

- 🔒 **企业级安全**：安全的密码处理、权限验证、操作审计
- 🚀 **一键配置**：自动完成系统优化和 POS 环境设置
- 📝 **详细日志**：完整的操作记录和错误追踪
- 💾 **智能备份**：自动备份重要配置，支持精确恢复
- 🔧 **易于维护**：清晰的代码结构和完善的文档
- 🔄 **完全可逆**：提供完整的系统恢复脚本

## 🎯 功能列表

### POS 系统配置 (`POS_Setup.ps1`)

- ✅ 禁用 Windows 商店和消费者功能
- ✅ 禁用自动更新（避免意外重启）
- ✅ 简化用户界面（移除不必要的元素）
- ✅ 配置安全的自动登录
- ✅ 安全和隐私加固
- ✅ 性能优化（禁用不必要的服务）
- ✅ 防火墙配置（内网访问，白名单服务）
  - 允许内网访问（192.168.x.x, 10.x.x.x, 172.16-31.x.x）
  - Python POS 服务器端口（8001-8004）
  - RustDesk 远程管理
  - Chrome Remote Desktop
  - Cloudflare 服务
  - HTTPS/HTTP/DNS 出站连接
- ✅ **RustDesk 远程管理配置**（自动安装为服务）
- ✅ POS 应用自动启动

### RustDesk 远程管理工具

**独立安装工具** - 如果需要单独安装或重新配置 RustDesk：

```batch
# 双击运行（需要管理员权限）
Install_RustDesk_Service.bat
```

**功能**：
- 🖥️ 自动安装 RustDesk 为 Windows 服务
- 🚀 配置服务自动启动
- 🔥 添加防火墙规则
- 🔐 可选设置永久密码
- ✅ 即使无人登录也能远程访问

📖 **详细指南**：查看 [RustDesk_Service_Guide.md](RustDesk_Service_Guide.md)

### 🔒 Kiosk Mode 锁定模式（新增）

**功能**：防止员工退出 POS 程序访问桌面，需要密码才能退出

```batch
# 双击运行配置工具（需要管理员权限）
Enable_Kiosk_Mode.bat
```

**四种锁定方案**：
- 🔥 **Shell Launcher**：最安全，完全替换系统 Shell（推荐，需要 Pro/Enterprise）
- 🖥️ **Assigned Access**：Windows 原生展台模式（需要 Pro/Enterprise）
- 🔐 **注册表锁定**：限制系统功能，支持所有版本（包括 Home）
- ⚙️ **自定义 Shell**：开机直接启动 POS，完全隐藏桌面（高级用户）

**核心功能**：
- ✅ 需要密码才能退出 POS 程序
- ✅ 禁用任务管理器和系统快捷键
- ✅ 防止访问桌面和文件系统
- ✅ 程序崩溃自动重启（Shell Launcher）
- ✅ 远程管理员可通过密码解锁
- ✅ 完全可逆，提供恢复方案

📖 **完整指南**：查看 [Kiosk_Mode_Guide.md](docs/Kiosk_Mode_Guide.md)

### 系统恢复 (`POS_restore.ps1`)

- ✅ 恢复 Windows 默认设置
- ✅ 重新启用系统服务
- ✅ 清除自动登录配置
- ✅ 重置防火墙规则
- ✅ 移除 POS 启动项
- ✅ 基于备份的精确恢复

## 🚀 快速开始

### 系统要求

#### ✅ 完全支持的系统
- **Windows 11 Pro / Enterprise / Education** (推荐)
- **Windows 10 Pro / Enterprise / Education** (Build 10240+)
  - 包括所有 Windows 10 版本：1507, 1511, 1607, 1703, 1709, 1803, 1809, 1903, 1909, 2004, 20H2, 21H1, 21H2, 22H2
- PowerShell 5.1 或更高版本（Windows 10/11 自带）
- 管理员权限

#### ⚠️ 有限支持
- **Windows 10 Home**: 可运行，但部分高级功能（组策略）不可用
- **Windows Server 2016/2019/2022**: 可运行，但某些桌面功能可能不适用

#### ❌ 不支持的系统
- Windows 8.1 及更早版本
- Windows 10 Build 10240 以下（初始预览版）

### 安装步骤

1. **下载工具包**
   ```powershell
   git clone https://github.com/[YOUR-USERNAME]/POS-Setup-Tools.git
   cd POS-Setup-Tools
   ```

2. **配置密码（推荐）**
   ```batch
   Set_POS_Password.bat
   ```

3. **运行设置脚本**
   ```batch
   cd "New POS Setup"
   POS_Setup.bat
   ```

4. **重启系统应用更改**

### 恢复系统

如需恢复到默认配置：

```batch
cd "Restore PC"
POS_restore.bat
```

## 📖 详细文档

- [安全使用指南](SECURITY_GUIDE.md) - 密码配置、安全注意事项
- [安全改进报告](SECURITY_IMPROVEMENTS.md) - 安全功能详解

## 🔐 安全特性

### 密码安全
- ❌ 无明文密码
- ✅ 环境变量支持
- ✅ 交互式安全输入
- ✅ 自动内存清理

### 操作审计
- ✅ 详细操作日志 (`C:\POS\Logs\`)
- ✅ 注册表备份 (`C:\POS\Backup\`)
- ✅ 服务状态备份
- ✅ 时间戳追踪

### 权限控制
- ✅ 管理员权限验证
- ✅ 系统兼容性检查
- ✅ 操作结果验证

## 📁 项目结构

```
POS-Setup-Tools/
├── New POS Setup/
│   ├── POS_Setup.bat               # 启动器
│   └── POS_Setup.ps1                # 主配置脚本
├── Restore PC/
│   ├── POS_restore.bat              # 恢复启动器
│   └── POS_restore.ps1              # 恢复脚本
├── Enable_Settings.bat              # 快速修复：重新启用 Settings
├── Enable_Kiosk_Mode.bat            # 🔒 Kiosk 模式配置工具（新增）
├── Enable_Kiosk_Mode.ps1            # Kiosk 模式配置脚本（新增）
├── Install_RustDesk_Service.bat     # RustDesk 服务安装
├── Install_RustDesk_Service.ps1     # RustDesk 服务安装脚本
├── Install_Epson_Printer.bat        # Epson 打印机安装工具
├── Install_Epson_Printer.ps1        # Epson 打印机安装脚本
├── Enable_Network_Sharing.bat       # 网络共享配置工具
├── Enable_Network_Sharing.ps1       # 网络共享配置脚本
├── Set_POS_Password.bat             # 密码设置工具
├── Test_Syntax.ps1                  # 语法验证工具
├── SECURITY_GUIDE.md                # 安全使用指南
├── SECURITY_IMPROVEMENTS.md         # 安全改进报告
├── TROUBLESHOOTING.md               # 故障排除指南（必读）
├── RustDesk_Service_Guide.md        # RustDesk 服务详细指南（新增）
├── QUICK_FIX_SETTINGS.md            # Settings 快速修复
├── Settings修复指南.md              # Settings 修复中文指南
├── .gitignore
└── README.md
```

## 🛠️ 使用示例

### 基本使用

```batch
# 1. 以管理员身份运行 PowerShell
# 2. 设置密码
Set_POS_Password.bat

# 3. 运行安装
cd "New POS Setup"
POS_Setup.bat
```

### 高级配置

```powershell
# 使用环境变量
$env:POS_PASSWORD = "YourSecurePassword"
.\POS_Setup.ps1

# 或者让脚本提示输入
.\POS_Setup.ps1  # 会自动提示安全输入密码
```

## ⚠️ 重要提示

1. **备份数据**：运行脚本前请备份重要数据
2. **测试环境**：建议先在测试机器上验证
3. **物理安全**：配置自动登录后确保设备物理安全
4. **定期更新**：保持系统和远程工具更新
5. **密码管理**：使用强密码并定期更换

## 🔧 故障排除

### ⚠️ 重要提示：运行 Setup 后无法打开 Settings？

运行 POS Setup 脚本后，Windows 设置（Settings）和控制面板会被禁用以防止误操作。

**快速解决方案**：

1. **一键修复（推荐）**：
   ```batch
   Enable_Settings.bat
   ```
   双击运行此文件即可重新启用 Settings

2. **手动命令**：
   ```powershell
   # 以管理员身份运行 PowerShell
   reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoControlPanel /f
   Stop-Process -Name explorer -Force
   Start-Process explorer
   ```

详细故障排除指南请查看 [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

### 常见问题

**Q: 提示需要管理员权限？**
A: 右键点击 PowerShell，选择"以管理员身份运行"

**Q: 执行策略错误？**
A: 运行 `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

**Q: 恢复后某些设置没有还原？**
A: 检查 `C:\POS\Backup\` 目录中的备份文件，可能需要手动导入

**Q: 无法访问外部网络？**
A: 脚本配置了严格防火墙。运行 `netsh advfirewall set allprofiles firewallpolicy blockinbound,allowoutbound` 允许出站流量

### 日志位置

- 安装日志：`C:\POS\Logs\setup_*.log`
- 恢复日志：`C:\POS\Logs\restore_*.log`
- 备份文件：`C:\POS\Backup\`

## 📜 版本历史

### v2.0 - 2025-10-14
- ✨ 新增安全密码处理机制
- 🔒 添加权限验证和系统检查
- 📝 实现详细日志记录
- 💾 增加自动备份功能
- 🔧 改进错误处理和恢复机制
- 📖 完善文档和使用指南

### v1.0 - 2025-10-14
- 🎉 初始版本发布
- ⚙️ 基本 POS 系统配置功能
- 🔄 系统恢复功能

## 👨‍💻 作者

**Cislink NL**
- POS 系统专业配置工具

## 📄 许可证

此项目为私有项目，仅供内部使用。

## 🤝 贡献

内部项目，如有改进建议请联系项目维护者。

## 📞 支持

如遇到问题：
1. 查看 [安全使用指南](SECURITY_GUIDE.md)
2. 检查日志文件 (`C:\POS\Logs\`)
3. 联系 IT 支持团队

---

**⚡ 快速提示**：首次使用建议先阅读 [SECURITY_GUIDE.md](SECURITY_GUIDE.md) 了解最佳实践！