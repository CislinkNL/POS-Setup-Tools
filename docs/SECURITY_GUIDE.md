# POS 系统配置脚本 - 安全使用指南

## 📋 概述

此脚本套件用于配置和恢复 Windows 11 POS 系统，现已包含多项安全增强功能。

## 🔒 安全改进

### 1. 密码安全
- **移除明文密码**：不再在脚本中硬编码密码
- **多种输入方式**：
  - 环境变量：`$env:POS_PASSWORD`
  - 交互式安全输入：使用 `Read-Host -AsSecureString`
  - 内存清理：执行后自动清除密码变量

### 2. 权限验证
- **管理员检查**：脚本启动时验证管理员权限
- **系统兼容性**：检查 Windows 版本兼容性

### 3. 日志与备份
- **详细日志**：所有操作记录到 `C:\POS\Logs\`
- **注册表备份**：自动备份到 `C:\POS\Backup\`
- **服务状态备份**：保存原始服务状态供恢复使用

### 4. 错误处理
- **增强的异常处理**：详细的错误信息和恢复建议
- **操作验证**：关键操作后验证结果

## 🚀 使用方法

### 安全的密码配置方式

#### 方式1：环境变量（推荐用于自动化）
```powershell
# 设置环境变量
$env:POS_PASSWORD = "your_secure_password"
# 运行脚本
.\POS_Setup.ps1
```

#### 方式2：交互式输入（推荐用于手动操作）
```powershell
# 直接运行脚本，系统会提示输入密码
.\POS_Setup.ps1
```

#### 方式3：完全移除自动登录
如果安全要求很高，可以选择不配置自动登录，改用：
- Windows Hello
- PIN 登录
- Kiosk 模式

### 执行步骤

1. **以管理员身份运行 PowerShell**
2. **导航到脚本目录**
3. **设置执行策略**（如需要）：
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
4. **运行设置脚本**：
   ```powershell
   .\POS_Setup.ps1
   ```

## 📁 生成的文件

### 日志文件
- `C:\POS\Logs\setup_YYYYMMDD_HHMMSS.log` - 设置日志
- `C:\POS\Logs\restore_YYYYMMDD_HHMMSS.log` - 恢复日志

### 备份文件
- `C:\POS\Backup\registry_backup_YYYYMMDD_HHMMSS.reg` - 注册表备份
- `C:\POS\Backup\services_backup_YYYYMMDD_HHMMSS.csv` - 服务状态备份

## ⚠️ 安全注意事项

### 1. 物理安全
- 自动登录配置后，确保设备物理安全
- 考虑使用设备加密（BitLocker）

### 2. 网络安全
- 脚本配置的防火墙规则允许内网访问
- 定期检查防火墙规则的有效性
- 监控网络连接和访问日志

### 3. 远程访问
- RustDesk 配置了自动启动
- 定期更新 RustDesk 到最新版本
- 使用强密码保护远程访问

### 4. 备份和恢复
- 定期测试恢复脚本
- 保留配置备份文件
- 在关键更改前创建系统还原点

## 🔧 故障排除

### ⚠️ 运行后无法打开 Windows Settings

这是最常见的问题。脚本为了防止用户误操作，会禁用 Windows 设置和控制面板。

**快速解决方案**：

1. **运行修复脚本**：
   ```batch
   Enable_Settings.bat
   ```

2. **使用 PowerShell 命令**（以管理员身份）：
   ```powershell
   reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoControlPanel /f
   Stop-Process -Name explorer -Force
   Start-Process explorer
   ```

3. **查看详细指南**：
   参考 [TROUBLESHOOTING.md](TROUBLESHOOTING.md) 了解更多解决方案

### 权限问题
```
错误：This script requires Administrator privileges!
解决：右键点击 PowerShell，选择"以管理员身份运行"
```

### 执行策略问题
```
错误：无法加载文件，因为此系统禁止执行脚本
解决：Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 服务恢复问题
```
如果服务恢复失败，可以：
1. 检查 C:\POS\Backup\ 目录中的备份文件
2. 手动导入注册表备份
3. 使用 services.msc 手动恢复服务
```

## 📞 支持

如遇到问题，请检查：
1. 日志文件中的详细错误信息
2. Windows 事件查看器中的相关事件
3. 确保系统满足最低要求（Windows 11）

## 🔄 版本历史

- **v2.0** (2025-10-14)
  - 添加安全密码处理
  - 增强错误处理和日志记录
  - 添加权限验证和系统检查
  - 改进备份和恢复机制

- **v1.0** (2025-10-14)
  - 初始版本
  - 基本POS系统配置功能