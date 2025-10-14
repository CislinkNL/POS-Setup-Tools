# 🚀 RustDesk 服务 - 快速参考卡

## 一键安装

```batch
# 双击运行（以管理员身份）
Install_RustDesk_Service.bat
```

## 常用命令

### 服务管理

```powershell
# 查看状态
Get-Service RustDesk

# 启动服务
Start-Service RustDesk

# 停止服务
Stop-Service RustDesk

# 重启服务
Restart-Service RustDesk
```

### 手动安装

```powershell
# 安装为服务
& "C:\Program Files\RustDesk\rustdesk.exe" --install-service

# 设置自动启动
Set-Service RustDesk -StartupType Automatic

# 启动服务
Start-Service RustDesk
```

### 设置密码

```powershell
# 设置永久密码
& "C:\Program Files\RustDesk\rustdesk.exe" --password "YourPassword123"
```

### 卸载服务

```powershell
# 停止并卸载
Stop-Service RustDesk -Force
& "C:\Program Files\RustDesk\rustdesk.exe" --uninstall-service
```

## 防火墙配置

```powershell
# 添加规则
netsh advfirewall firewall add rule name="RustDesk" dir=in action=allow program="C:\Program Files\RustDesk\rustdesk.exe" enable=yes

# 删除规则
netsh advfirewall firewall delete rule name="RustDesk"
```

## 故障排除

### 服务无法启动

```powershell
# 检查进程
Get-Process rustdesk -ErrorAction SilentlyContinue

# 如果有进程，先停止
Stop-Process -Name rustdesk -Force

# 重新启动服务
Start-Service RustDesk
```

### 重新安装

```batch
# 最简单：运行安装脚本
Install_RustDesk_Service.bat
```

## 验证安装

```powershell
# 检查服务
Get-Service RustDesk | Format-Table Name, Status, StartType

# 检查防火墙
netsh advfirewall firewall show rule name="RustDesk"

# 检查版本
& "C:\Program Files\RustDesk\rustdesk.exe" --version
```

## 重要提示

- ✅ 服务模式：即使无人登录也能远程访问
- 🔐 建议设置永久密码
- 🔥 确保防火墙规则已添加
- 🔄 定期更新到最新版本

## 完整文档

📖 查看详细指南: [RustDesk_Service_Guide.md](RustDesk_Service_Guide.md)

---

**最后更新**: 2025-10-14