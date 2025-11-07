# 📚 文档索引 - POS Setup Tools

## 📖 核心文档（必读）

### 🚀 [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)

**日常运维必备手册** - 所有常用命令和快速修复方案的集合

**包含内容**：
- Windows 系统常用命令
- 网络配置（IP、DNS、网卡设置）
- 打印机配置和故障排除
- 语言和区域设置
- 系统管理工具快捷方式
- 防火墙配置
- RustDesk 远程管理
- 常见问题快速修复

**使用场景**: 现场部署、日常维护、故障排除

---

### 📘 [README.md](./README.md)

**项目说明和快速开始指南**

**包含内容**：
- 项目概述和功能列表
- 快速开始步骤
- 安全特性说明
- 基本使用方法

**使用场景**: 了解项目、首次使用

---

### ⚠️ [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

**详细故障排除指南**

**包含内容**：
- Settings 无法打开（最常见）
- 网络访问问题
- Windows Update 问题
- 自动登录问题
- RustDesk 连接问题
- POS 程序启动问题
- 服务恢复问题

**使用场景**: 遇到问题时查阅

---

## 📂 详细文档（docs/ 目录）

### 安全相关

- [`SECURITY_GUIDE.md`](./docs/SECURITY_GUIDE.md) - 安全使用指南
- [`SECURITY_IMPROVEMENTS.md`](./docs/SECURITY_IMPROVEMENTS.md) - 安全改进说明
- [`Firewall_Whitelist_CN.md`](./docs/Firewall_Whitelist_CN.md) - 🔥 **防火墙白名单配置**（中文）
- [`Firewall_Whitelist_NL.md`](./docs/Firewall_Whitelist_NL.md) - 🔥 **Firewall Whitelist Configuratie**（荷兰文）

### RustDesk 远程管理

- [`RustDesk_Cislink_Version.md`](./docs/RustDesk_Cislink_Version.md) - 🔥 **Cislink 预配置版本说明**
  - 即装即用，无需手动配置
  - 服务器地址和密钥已预设
  - 批量部署指南
- [`RustDesk_Service_Guide.md`](./docs/RustDesk_Service_Guide.md) - 完整安装和配置指南
- [`RustDesk_Quick_Reference.md`](./docs/RustDesk_Quick_Reference.md) - 快速命令参考
- [`RustDesk_Implementation_Report.md`](./docs/RustDesk_Implementation_Report.md) - 实施报告

### Settings 修复

- [`QUICK_FIX_SETTINGS.md`](./docs/QUICK_FIX_SETTINGS.md) - 快速修复指南
- [`Settings修复指南.md`](./docs/Settings修复指南.md) - 中文详细指南

### 打印机安装

- [`Epson_POS_Printer_Guide.md`](./docs/Epson_POS_Printer_Guide.md) - 🖨️ Epson POS 打印机完整安装指南
  - 支持型号：TM-T20/T20II/T20III/T20X, TM-M30/M30II/M30III, TM-T88V/T88VI
  - USB 和网络安装步骤
  - 故障排除和高级配置

### 项目信息

- [`REPO_INFO.md`](./docs/REPO_INFO.md) - 仓库信息和 Git 使用
- [`UPDATE_SUMMARY.md`](./docs/UPDATE_SUMMARY.md) - 更新摘要

---

## 🎯 快速查找表

| 我想... | 查看文档 | 章节/命令 |
|---------|----------|-----------|
| **配置网卡 IP** | [QUICK_REFERENCE.md](./QUICK_REFERENCE.md#网络配置) | 🌐 网络配置 |
| **添加打印机** | [QUICK_REFERENCE.md](./QUICK_REFERENCE.md#打印机配置) | 🖨️ 打印机配置 |
| **更改系统语言** | [QUICK_REFERENCE.md](./QUICK_REFERENCE.md#语言和区域设置) | 🌍 语言和区域设置 |
| **Settings 打不开** | [QUICK_REFERENCE.md](./QUICK_REFERENCE.md#settings-无法打开) | ⚠️ Settings 无法打开 |
| **配置远程访问** | [QUICK_REFERENCE.md](./QUICK_REFERENCE.md#rustdesk-远程管理) | 🖥️ RustDesk 远程管理 |
| **管理服务** | [QUICK_REFERENCE.md](./QUICK_REFERENCE.md#系统管理工具) | ⚙️ 系统管理工具 |
| **配置防火墙** | [QUICK_REFERENCE.md](./QUICK_REFERENCE.md#防火墙配置) | 🔥 防火墙配置 |
| **完整安装 POS** | [README.md](./README.md#快速开始) | 快速开始 |
| **解决复杂问题** | [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) | 按问题类型查找 |
| **RustDesk 详细配置** | [docs/RustDesk_Service_Guide.md](./docs/RustDesk_Service_Guide.md) | 完整指南 |

---

## 🔧 常用工具快捷方式

```batch
# Windows 系统工具
Win + R → netplwiz          # 用户管理
Win + R → services.msc      # 服务管理
Win + R → ncpa.cpl          # 网络连接
Win + R → control printers  # 打印机设置
Win + R → intl.cpl          # 区域设置
Win + R → firewall.cpl      # 防火墙设置

# POS 专用脚本
Enable_Settings.bat         # 修复 Settings
Install_RustDesk_Service.bat # 安装远程管理
POS_Setup.bat              # 完整 POS 配置
POS_restore.bat            # 恢复默认设置
```

---

## 📱 移动端/打印版

**QUICK_REFERENCE.md** 适合打印或转换为 PDF，在现场没有电脑访问时使用。

建议：
1. 打印 QUICK_REFERENCE.md 并层压保护
2. 或转换为 PDF 保存在手机上
3. 或添加到浏览器收藏夹

---

## 🔄 文档更新

- **QUICK_REFERENCE.md** - 随时更新，包含最新命令
- **TROUBLESHOOTING.md** - 根据实际问题持续补充
- **docs/** - 详细文档，定期维护

---

**最后更新**: 2025-10-14  
**文档结构版本**: v3.0

💡 **提示**: 99% 的日常问题都能在 QUICK_REFERENCE.md 中找到解决方案！