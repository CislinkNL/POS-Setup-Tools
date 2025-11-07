# 🔒 Kiosk Mode 完全指南

## 概述

Kiosk Mode（锁定模式）可以防止员工退出 POS 程序访问桌面，确保系统只用于指定用途。

## 🎯 为什么需要 Kiosk Mode？

### 常见问题
- ❌ 员工可以随意关闭 POS 程序
- ❌ 可以访问桌面浏览文件
- ❌ 可以安装未授权的软件
- ❌ 可以修改系统设置
- ❌ 可以访问互联网浏览

### 解决方案
- ✅ 锁定 POS 程序为全屏
- ✅ 需要密码才能退出
- ✅ 禁用系统快捷键
- ✅ 限制访问系统功能
- ✅ 员工只能使用 POS 功能

---

## 📊 四种 Kiosk Mode 方案对比

| 方案 | 安全级别 | 适用系统 | 难度 | 推荐度 |
|-----|---------|---------|------|--------|
| **1. Shell Launcher** | ⭐⭐⭐⭐⭐ | Pro/Enterprise | 中等 | ⭐⭐⭐⭐⭐ |
| **2. Assigned Access** | ⭐⭐⭐⭐ | Pro/Enterprise | 简单 | ⭐⭐⭐⭐ |
| **3. 注册表锁定** | ⭐⭐⭐ | 所有版本 | 简单 | ⭐⭐⭐ |
| **4. 自定义 Shell** | ⭐⭐⭐⭐⭐ | 所有版本 | 困难 | ⭐⭐ |

---

## 🔥 方案 1: Shell Launcher（推荐）

### 优点
- ✅ **最安全**：完全替换系统 Shell
- ✅ **专业级**：微软官方企业解决方案
- ✅ **密码保护**：自定义退出密码
- ✅ **自动重启**：程序崩溃自动重新启动
- ✅ **易于管理**：图形化退出界面

### 缺点
- ❌ 需要 Windows 10/11 Pro 或 Enterprise
- ❌ 需要重启系统生效

### 适用场景
- 餐厅 POS 系统（推荐）
- 自助服务终端
- 信息查询终端
- 专用工作站

### 使用步骤

#### 配置 Kiosk Mode
```batch
# 1. 以管理员身份运行
Enable_Kiosk_Mode.bat

# 2. 选择选项 1 (Shell Launcher)

# 3. 输入 POS 程序路径
输入: C:\POS\app.exe

# 4. 设置退出密码
输入您的安全密码（至少 8 位）

# 5. 重启系统
```

#### 退出 Kiosk Mode
```
方法 1: 桌面快捷方式
  - 双击 "退出Kiosk模式" 快捷方式
  - 输入管理员密码
  - 点击确定

方法 2: 远程访问
  - 使用 RustDesk 或 Chrome RD 远程连接
  - 运行: C:\POS\Config\Exit_Kiosk.ps1
  - 输入密码

方法 3: 安全模式
  - 重启进入安全模式
  - 手动禁用 Shell Launcher
```

### 配置文件位置
- **配置**: `C:\POS\Config\kiosk_config.json`
- **退出脚本**: `C:\POS\Config\Exit_Kiosk.ps1`
- **桌面快捷方式**: `公共桌面\退出Kiosk模式.lnk`

### 技术细节
```powershell
# Shell Launcher 注册表位置
HKLM\SOFTWARE\Microsoft\Windows Embedded\EmbeddedLogon

# 密码加密方式
Base64(UTF8(Password))
```

---

## 🖥️ 方案 2: Assigned Access（简单）

### 优点
- ✅ **图形化配置**：Windows 设置界面
- ✅ **简单易用**：无需脚本
- ✅ **官方支持**：微软原生功能
- ✅ **安全可靠**：系统级隔离

### 缺点
- ❌ 需要 Pro/Enterprise 版本
- ❌ 只支持 UWP 应用或 Edge
- ❌ 传统 Win32 程序支持有限

### 适用场景
- UWP POS 应用
- 基于 Web 的 POS 系统
- Edge 浏览器 Kiosk

### 配置步骤

#### 方法 1: Windows 设置
```
1. 打开设置
   Win + I → 账户 → 家庭和其他用户

2. 设置展台
   点击 "设置展台" → 创建展台账户

3. 选择应用
   选择您的 POS 应用

4. 完成配置
   系统将创建受限账户
```

#### 方法 2: PowerShell 配置
```powershell
# 创建展台用户
$Username = "POSKiosk"
$Password = ConvertTo-SecureString "Password123" -AsPlainText -Force
New-LocalUser -Name $Username -Password $Password -FullName "POS Kiosk"

# 配置 Assigned Access (需要应用 AUMID)
Set-AssignedAccess -UserName $Username -AppUserModelId "YourApp_AUMID"
```

#### 退出方法
```
Ctrl + Alt + Del
  → 切换用户
  → 登录管理员账户
```

---

## 🔐 方案 3: 注册表锁定（通用）

### 优点
- ✅ **兼容性好**：支持所有 Windows 版本
- ✅ **无需 Pro**：Home 版本也可用
- ✅ **轻量级**：无需额外功能
- ✅ **密码保护**：自定义解锁密码

### 缺点
- ❌ 安全性较低：可通过安全模式绕过
- ❌ 不是完全锁定：熟练用户可能绕过

### 适用场景
- Windows 10/11 Home 版本
- 临时锁定需求
- 不太重要的场景

### 限制功能
```
✓ 禁用任务管理器 (Ctrl+Alt+Del)
✓ 隐藏桌面图标
✓ 禁用右键菜单
✓ 禁用 Windows 快捷键
✓ 禁用 Alt+Tab
✓ 禁用注销和关机
✓ 锁定任务栏
```

### 使用步骤

#### 启用锁定
```batch
# 1. 运行配置工具
Enable_Kiosk_Mode.bat

# 2. 选择选项 3 (注册表锁定)

# 3. 确认应用限制
输入: y

# 4. 设置解锁密码
输入您的密码

# 5. 重启 Explorer
系统自动重启 Explorer
```

#### 解锁方法
```powershell
# 方法 1: 运行解锁脚本（需要管理员权限）
powershell -ExecutionPolicy Bypass -File "C:\POS\Config\Unlock_Kiosk.ps1"
输入密码

# 方法 2: 手动删除注册表
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoWinKeys /f
# ... 删除其他限制

# 方法 3: 恢复备份
regedit.exe
导入: C:\POS\Backup\kiosk_registry_backup_*.reg
```

### 注册表修改位置
```
HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System
HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
```

---

## ⚙️ 方案 4: 自定义 Shell（高级）

### 优点
- ✅ **完全替换**：不显示 Windows 桌面
- ✅ **最彻底**：开机直接进入 POS
- ✅ **支持所有版本**：Home 也可用

### 缺点
- ❌ **风险最高**：配置错误可能导致系统无法使用
- ❌ **难以恢复**：需要安全模式或远程访问
- ❌ **不推荐新手**：需要技术经验

### 适用场景
- 专用 POS 终端（无其他用途）
- 有技术支持团队
- 不需要访问 Windows 功能

### ⚠️ 重要警告

```
⚠️ 使用前必读：
  1. 确保 POS 程序路径 100% 正确
  2. 确保 POS 程序可以独立运行
  3. 必须有备份恢复方案
  4. 建议先在虚拟机测试
  5. 确保有远程访问工具（RustDesk）
```

### 配置步骤

#### 启用自定义 Shell
```batch
# 1. 运行配置工具
Enable_Kiosk_Mode.bat

# 2. 选择选项 4 (自定义 Shell)

# 3. 确认警告
输入: YES

# 4. 输入 POS 程序路径
输入: C:\POS\app.exe

# 5. 备份完成
自动备份到 C:\POS\Backup\

# 6. 重启系统
重启后将直接启动 POS 程序
```

#### 恢复 Explorer Shell
```powershell
# 方法 1: 远程访问
RustDesk 远程连接 → 打开 PowerShell
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "explorer.exe" /f
重启系统

# 方法 2: 安全模式
1. 重启按 F8 进入安全模式
2. 以管理员身份运行 PowerShell
3. reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "explorer.exe" /f
4. 重启正常模式

# 方法 3: 导入备份
regedit.exe
导入: C:\POS\Backup\shell_backup_*.reg
重启
```

### 注册表位置
```
HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
  Shell = "C:\POS\app.exe"

默认值:
  Shell = "explorer.exe"
```

---

## 🛡️ 安全最佳实践

### 密码管理
1. **使用强密码**
   - 至少 12 位字符
   - 包含大小写字母、数字、符号
   - 不要使用常见密码

2. **定期更换**
   - 每 3-6 个月更换一次
   - 离职员工后立即更换

3. **安全存储**
   - 不要写在纸上
   - 使用密码管理器
   - 只告知授权管理员

### 备份策略
```
✓ 配置前自动备份
✓ 备份保存在: C:\POS\Backup\
✓ 包含注册表导出文件
✓ 定期测试恢复流程
✓ 异地备份配置文件
```

### 远程访问
```
✓ 保持 RustDesk 服务运行
✓ 保持 Chrome Remote Desktop 可用
✓ 记录远程访问凭据
✓ 定期测试远程连接
✓ 准备备用访问方案
```

### 应急预案
```
1. 密码丢失
   → 使用安全模式恢复
   → 或远程访问重置

2. 程序崩溃
   → Shell Launcher 自动重启
   → 或远程终止进程

3. 配置错误
   → 导入注册表备份
   → 或重装系统

4. 系统故障
   → 准备恢复 U 盘
   → 或使用系统还原点
```

---

## 🧪 测试检查清单

### 配置前
- [ ] 备份重要数据
- [ ] 创建系统还原点
- [ ] 测试 POS 程序正常运行
- [ ] 验证 RustDesk 远程访问可用
- [ ] 记录当前系统配置

### 配置后
- [ ] 测试 POS 程序启动
- [ ] 测试退出密码是否有效
- [ ] 测试系统快捷键被禁用
- [ ] 测试远程访问功能
- [ ] 测试程序崩溃后自动重启
- [ ] 测试解锁/恢复流程

### 定期检查
- [ ] 每月测试退出流程
- [ ] 每季度更换密码
- [ ] 每半年测试恢复备份
- [ ] 记录所有配置变更
- [ ] 培训新管理员

---

## 📞 故障排除

### 问题 1: 忘记退出密码

**症状**: 无法退出 Kiosk 模式

**解决方案**:
```powershell
# 方法 1: 查看配置文件
notepad C:\POS\Config\kiosk_config.json
# 密码已加密，需要解密

# 方法 2: 重置配置
# 进入安全模式
删除: C:\POS\Config\kiosk_config.json
重新运行: Enable_Kiosk_Mode.bat

# 方法 3: 完全禁用
# 安全模式下删除所有 Kiosk 配置
```

### 问题 2: POS 程序无法启动

**症状**: 黑屏或错误提示

**解决方案**:
```
1. 检查程序路径是否正确
2. 检查程序依赖是否安装
3. 查看事件查看器中的错误日志
4. 临时切换回 Explorer Shell 诊断
```

### 问题 3: 系统快捷键仍然有效

**症状**: Ctrl+Alt+Del 仍可使用

**解决方案**:
```powershell
# 检查注册表设置
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr

# 重新应用限制
Enable_Kiosk_Mode.bat → 选项 3
```

### 问题 4: 无法远程访问

**症状**: RustDesk 连接失败

**解决方案**:
```
1. 检查 RustDesk 服务状态
   Get-Service RustDesk

2. 检查防火墙规则
   Get-NetFirewallRule -DisplayName "*RustDesk*"

3. 使用备用方案
   Chrome Remote Desktop
```

---

## 📖 参考资料

### 微软官方文档
- [Shell Launcher](https://docs.microsoft.com/en-us/windows/iot/iot-enterprise/customize/shell-launcher)
- [Assigned Access](https://docs.microsoft.com/en-us/windows/configuration/assigned-access/)
- [Kiosk Mode](https://docs.microsoft.com/en-us/windows/configuration/kiosk-methods)

### 相关脚本
- `Enable_Kiosk_Mode.bat` - 主配置脚本
- `Enable_Kiosk_Mode.ps1` - PowerShell 实现
- `C:\POS\Config\Exit_Kiosk.ps1` - 退出脚本
- `C:\POS\Config\Unlock_Kiosk.ps1` - 解锁脚本

### 其他文档
- `SECURITY_GUIDE.md` - 安全指南
- `TROUBLESHOOTING.md` - 故障排除
- `QUICK_REFERENCE.md` - 快速参考

---

**最后更新**: 2025-11-07
**版本**: 1.0
**作者**: Cislink NL
**联系**: WhatsApp +31 6 45528708 (Yongka)
