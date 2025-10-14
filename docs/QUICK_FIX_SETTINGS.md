# 🚨 运行 POS Setup 后无法打开 Settings？

## 快速解决方案

### 方法 1: 一键修复（最简单）

**双击运行以下文件**：
```
Enable_Settings.bat
```

### 方法 2: PowerShell 命令

**以管理员身份运行 PowerShell**，复制粘贴以下命令：

```powershell
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoControlPanel /f
Stop-Process -Name explorer -Force
Start-Process explorer
Write-Host "✓ Settings 已重新启用！按 Win+I 打开设置" -ForegroundColor Green
```

### 方法 3: 使用注册表编辑器

1. 按 `Win + R` 输入 `regedit`
2. 导航到：`HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer`
3. 删除 `NoControlPanel` 项
4. 重启 Explorer 或重启电脑

---

## 为什么会这样？

POS Setup 脚本为了安全和防止误操作，会禁用 Windows 设置访问。这是正常的 POS 系统配置行为。

如果您需要临时访问设置，使用上述方法即可。

---

## 需要更多帮助？

查看完整的 [故障排除指南 (TROUBLESHOOTING.md)](TROUBLESHOOTING.md)

---

**快速测试**：按 `Win + I` 看是否能打开设置

**恢复所有设置**：运行 `Restore PC\POS_restore.bat`