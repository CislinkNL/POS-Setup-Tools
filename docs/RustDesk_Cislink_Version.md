# 🖥️ Cislink RustDesk 预配置版本说明

## 📋 概述

Cislink 提供预先配置好的 RustDesk 客户端，无需手动配置服务器地址和密钥，安装即可使用。

---

## 🔥 主要优势

### ✅ 即装即用
- 服务器地址已预设（连接到 Cislink 服务器）
- 密钥已预配置
- 无需手动输入任何配置信息

### ✅ 统一管理
- 所有 POS 终端连接到同一 Cislink 服务器
- 便于集中管理和监控
- 统一的访问控制

### ✅ 自动化部署
- `Install_RustDesk_Service.bat` 脚本自动下载安装
- 一键部署到多台设备
- 适合批量安装

---

## 📥 下载和安装

### 方法 1: 使用自动安装脚本（推荐）

```batch
# 双击运行（需要管理员权限）
Install_RustDesk_Service.bat
```

脚本会自动：
1. 从 Cislink 服务器下载预配置客户端
2. 安装 RustDesk
3. 配置为 Windows 服务
4. 启动服务

### 方法 2: 手动下载安装

**下载地址**：
```
https://cislink.nl/radmin/RustDesk_Cislink_Setup.exe
```

**安装步骤**：
1. 下载安装包
2. 以管理员身份运行安装程序
3. 按照向导完成安装
4. 安装后自动连接到 Cislink 服务器

---

## 🔧 配置说明

### 预配置内容

Cislink 版本已包含以下预配置：

| 配置项 | 说明 |
|--------|------|
| **服务器地址** | Cislink RustDesk 中继服务器 |
| **API 服务器** | Cislink API 服务器地址 |
| **公钥** | Cislink 服务器公钥 |
| **自动连接** | 启动时自动连接到服务器 |

### 无需手动配置

与官方版本不同，Cislink 版本：
- ❌ 不需要手动输入服务器地址
- ❌ 不需要手动输入公钥
- ❌ 不需要配置 ID 服务器
- ✅ 安装完成即可使用

---

## 🚀 使用方法

### 安装后首次使用

1. **查看设备 ID**
   - 打开 RustDesk 客户端
   - 查看"您的桌面 ID"
   - 记录此 ID（用于远程连接）

2. **设置永久密码**（可选但推荐）
   ```powershell
   & "C:\Program Files\RustDesk\rustdesk.exe" --password "YourPassword123"
   ```
   
   或在 RustDesk 界面中设置

3. **验证连接**
   - 检查界面显示"就绪"
   - 确认已连接到 Cislink 服务器
   - 绿色状态表示正常连接

### 远程连接到此设备

**从其他设备连接**：
1. 打开 RustDesk（也需要是 Cislink 版本）
2. 输入目标设备的 ID
3. 输入密码（如果已设置）
4. 点击"连接"

---

## 🔐 安全建议

### 1. 设置强密码

```powershell
# 使用强密码（至少 12 位，包含大小写字母、数字、符号）
& "C:\Program Files\RustDesk\rustdesk.exe" --password "Cislink@2025!Secure"
```

### 2. 定期更换密码

```powershell
# 每 3-6 个月更换一次密码
& "C:\Program Files\RustDesk\rustdesk.exe" --password "NewPassword123!"
```

### 3. 记录设备 ID

- 保存每台 POS 设备的 RustDesk ID
- 建立 ID 与设备的对应关系
- 便于快速定位和连接

### 4. 监控连接日志

- 定期检查连接日志
- 发现异常连接及时处理

---

## 🛠️ 服务管理

### 查看服务状态

```powershell
# PowerShell
Get-Service RustDesk

# 或使用 UI
services.msc
```

### 重启服务

```powershell
# 重启 RustDesk 服务
Restart-Service RustDesk
```

### 设置服务自动启动

```powershell
# 确保服务设置为自动启动
Set-Service -Name RustDesk -StartupType Automatic
```

---

## ⚠️ 故障排除

### 问题 1: 显示"未就绪"或"离线"

**解决方案**：

```powershell
# 1. 检查服务状态
Get-Service RustDesk

# 2. 重启服务
Restart-Service RustDesk

# 3. 检查网络连接
Test-NetConnection -ComputerName cislink.nl -Port 21116

# 4. 检查防火墙
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*RustDesk*"}
```

### 问题 2: 无法连接到设备

**检查清单**：
- [ ] 目标设备 RustDesk 服务是否运行
- [ ] 目标设备是否在线（网络连接正常）
- [ ] 设备 ID 是否正确
- [ ] 密码是否正确
- [ ] 两台设备都使用 Cislink 版本

### 问题 3: 连接缓慢或断开

**优化步骤**：
1. 检查网络质量
2. 重启 RustDesk 服务
3. 检查系统资源占用
4. 更新到最新版本

---

## 📊 批量部署

### 场景：为多台 POS 设备安装

**准备工作**：
1. 准备安装脚本：`Install_RustDesk_Service.bat`
2. 准备 USB 驱动器或网络共享
3. 记录表格（设备名称、IP 地址、RustDesk ID）

**部署流程**：

```batch
# 在每台设备上执行
1. 以管理员身份运行 Install_RustDesk_Service.bat
2. 等待安装完成
3. 打开 RustDesk 记录 ID
4. 设置永久密码
5. 测试远程连接
```

**批量密码设置脚本**：

```powershell
# 批量设置相同密码（可用于初始部署）
$Password = "Cislink@2025!POS"
$RustDeskPath = "C:\Program Files\RustDesk\rustdesk.exe"

if (Test-Path $RustDeskPath) {
    & $RustDeskPath --password $Password
    Write-Host "✓ 密码已设置" -ForegroundColor Green
} else {
    Write-Host "❌ 未找到 RustDesk" -ForegroundColor Red
}
```

---

## 📝 设备清单模板

建议为每个部署创建设备清单：

| 设备编号 | 设备名称 | IP 地址 | RustDesk ID | 密码 | 安装日期 | 备注 |
|---------|---------|---------|-------------|------|---------|------|
| POS-001 | 收银台1 | 192.168.1.101 | 123456789 | ******* | 2025-10-14 | 正常 |
| POS-002 | 收银台2 | 192.168.1.102 | 987654321 | ******* | 2025-10-14 | 正常 |
| POS-003 | 后厨打印 | 192.168.1.103 | 456789123 | ******* | 2025-10-14 | 正常 |

---

## 🔗 相关资源

### 文档
- 完整安装指南：`docs/RustDesk_Service_Guide.md`
- 快速参考：`QUICK_REFERENCE.md`

### 工具
- 自动安装脚本：`Install_RustDesk_Service.bat`
- POS Setup 脚本：`New POS Setup/POS_Setup.bat`

### 下载
- Cislink 版本：https://cislink.nl/radmin/RustDesk_Cislink_Setup.exe
- 官方版本：https://rustdesk.com/（需要手动配置）

---

## 💡 最佳实践

### 1. 标准化部署
- 所有 POS 设备使用统一的安装脚本
- 使用一致的密码策略
- 记录所有设备的 ID 和信息

### 2. 定期维护
- 每月检查服务状态
- 定期更新密码
- 测试远程连接

### 3. 备份配置
- 记录设备 ID 和密码
- 保存设备清单
- 定期备份配置信息

### 4. 培训团队
- 培训技术人员使用 RustDesk
- 建立远程支持流程
- 记录常见问题和解决方案

---

## 📞 技术支持

### Cislink 支持
- 如有 Cislink RustDesk 版本相关问题
- 请联系 Cislink 技术支持团队

### 常见问题
- 查看：`docs/RustDesk_Service_Guide.md`
- 或参考：`TROUBLESHOOTING.md`

---

**最后更新**: 2025-10-14  
**版本**: Cislink v1.0  
**适用**: Windows 11/10

💡 **提示**: Cislink 预配置版本是为 POS 环境优化的版本，推荐用于所有 Cislink POS 部署！
