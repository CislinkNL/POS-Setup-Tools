# 🔥 防火墙白名单配置说明

## 概述

POS Setup 脚本配置 Windows 防火墙，在保护系统安全的同时，确保必要的服务能够正常通信。

## 防火墙策略

**默认策略**: 阻止所有入站和出站流量
**例外情况**: 仅允许内网和白名单服务

## ✅ 允许的网络（内网）

| 网络范围 | 说明 |
|---------|------|
| `192.168.0.0/16` | 私有网络 (C类) |
| `10.0.0.0/8` | 私有网络 (A类) |
| `172.16.0.0/12` | 私有网络 (B类) |
| `127.0.0.1` | 本地回环 (localhost) |

## ✅ 白名单服务

### 1. Python POS 服务器端口
- **端口**: TCP 8001, 8002, 8003, 8004
- **方向**: 入站 & 出站
- **用途**: POS 应用程序通信
- **规则名称**: `POS Python Server Inbound/Outbound`

### 2. RustDesk 远程管理
- **程序**: `C:\Program Files\RustDesk\rustdesk.exe`
- **方向**: 入站 & 出站
- **用途**: 远程技术支持访问
- **规则名称**: `RustDesk Service` / `RustDesk Service Out`
- **版本**: Cislink 预配置客户端

### 3. Chrome Remote Desktop
- **程序**: `remoting_host.exe`
- **位置**:
  - `%LOCALAPPDATA%\Google\Chrome Remote Desktop\*\remoting_host.exe`
  - `C:\Program Files (x86)\Google\Chrome Remote Desktop\*\remoting_host.exe`
- **方向**: 入站 & 出站
- **用途**: 备用远程访问方案
- **规则名称**: `Chrome Remote Desktop` / `Chrome Remote Desktop Out`

### 4. Cloudflare 服务
- **程序**: `cloudflared.exe`
- **位置**:
  - `C:\Program Files\cloudflared\cloudflared.exe`
  - `%LOCALAPPDATA%\cloudflared\cloudflared.exe`
  - `C:\cloudflared\cloudflared.exe`
- **方向**: 入站 & 出站
- **用途**: Cloudflare Tunnel 连接
- **规则名称**: `Cloudflare Tunnel` / `Cloudflare Tunnel Out`

### 5. HTTPS/HTTP 出站连接
- **端口**: TCP 443 (HTTPS), TCP 80 (HTTP)
- **方向**: 出站
- **用途**: Web 访问、更新、云服务
- **规则名称**: `HTTPS Outbound` / `HTTP Outbound`

### 6. DNS 出站连接
- **端口**: UDP 53, TCP 53
- **方向**: 出站
- **用途**: 域名解析
- **规则名称**: `DNS Outbound` / `DNS TCP Outbound`

## 📋 防火墙规则管理

### 查看所有 POS 相关规则
```powershell
Get-NetFirewallRule | Where-Object {
    $_.DisplayName -like "*POS*" -or
    $_.DisplayName -like "*RustDesk*" -or
    $_.DisplayName -like "*Chrome Remote*" -or
    $_.DisplayName -like "*Cloudflare*"
} | Format-Table DisplayName, Enabled, Direction, Action
```

### 检查特定规则
```powershell
# Python 服务器端口
Get-NetFirewallRule -DisplayName "POS Python Server*"

# RustDesk
Get-NetFirewallRule -DisplayName "RustDesk*"

# Chrome Remote Desktop
Get-NetFirewallRule -DisplayName "Chrome Remote Desktop*"

# Cloudflare
Get-NetFirewallRule -DisplayName "Cloudflare*"
```

### 手动添加规则
```powershell
# 示例：添加额外端口
netsh advfirewall firewall add rule name="POS Extra Port" dir=in action=allow protocol=TCP localport=9000
```

### 删除规则
```powershell
netsh advfirewall firewall delete rule name="POS Extra Port"
```

## 🔒 安全注意事项

1. **最小权限原则**: 仅开放必要的服务
2. **双向控制**: 入站和出站流量都受控制
3. **程序绑定**: 服务规则绑定到特定的可执行文件
4. **可恢复性**: 所有规则可通过 `POS_restore.ps1` 移除

## ⚠️ 重要警告

- **不要修改默认策略** 除非经过充分测试
- **在测试环境中验证** 所有更改
- **记录所有手动修改** 便于后续维护
- **定期备份配置** 用于灾难恢复

## 🛠️ 故障排除

### 服务被防火墙阻止
1. 检查规则是否存在:
   ```powershell
   Get-NetFirewallRule -DisplayName "<规则名称>"
   ```

2. 检查规则是否启用:
   ```powershell
   Get-NetFirewallRule -DisplayName "<规则名称>" | Select-Object Enabled
   ```

3. 测试连接:
   ```powershell
   Test-NetConnection -ComputerName <IP地址> -Port <端口>
   ```

### 手动重建规则
```powershell
# 示例：Python 服务器端口
netsh advfirewall firewall delete rule name="POS Python Server Inbound"
netsh advfirewall firewall add rule name="POS Python Server Inbound" dir=in action=allow protocol=TCP localport=8001,8002,8003,8004
```

## 📊 配置详情对照表

| 服务 | 端口/程序 | 入站 | 出站 | 备注 |
|-----|----------|-----|-----|------|
| Python POS | 8001-8004/TCP | ✅ | ✅ | 核心 POS 服务 |
| RustDesk | rustdesk.exe | ✅ | ✅ | Cislink 预配置版本 |
| Chrome RD | remoting_host.exe | ✅ | ✅ | 备用远程访问 |
| Cloudflare | cloudflared.exe | ✅ | ✅ | Tunnel 服务 |
| HTTPS | 443/TCP | ❌ | ✅ | 仅出站 |
| HTTP | 80/TCP | ❌ | ✅ | 仅出站 |
| DNS | 53/UDP+TCP | ❌ | ✅ | 仅出站 |
| 内网 | 192.168.x.x | ✅ | ✅ | 完全开放 |

## 📞 技术支持

遇到防火墙问题时:
- 查看日志: `C:\POS\Logs\setup_*.log`
- 参考文档: `README.md`, `QUICK_REFERENCE.md`
- 联系: IT 技术支持团队

## 🔄 自动化脚本

### 快速启用所有白名单规则
```powershell
# 运行完整 POS Setup
cd "New POS Setup"
.\POS_Setup.bat
```

### 快速禁用所有规则（恢复默认）
```powershell
# 运行恢复脚本
cd "Restore PC"
.\POS_restore.bat
```

---

**最后更新**: 2025-11-07
**版本**: 3.1
**作者**: Cislink NL
**联系**: WhatsApp 31645528708 (Yongka)
