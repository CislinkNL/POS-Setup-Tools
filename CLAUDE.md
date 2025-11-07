# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Windows 11 POS (Point of Sale) system configuration toolkit for Cislink NL. It provides automated scripts to configure, optimize, and manage Windows 11 Pro machines for POS environments, including remote management, network setup, and printer configuration.

**Primary Language**: PowerShell with Batch launchers
**Target Platform**: Windows 11 Pro
**Execution Requirements**: Administrator privileges required for all scripts

## Core Architecture

### Main Setup Flow
1. **POS_Setup.ps1** - Main configuration script that:
   - Disables Windows Store and consumer features
   - Disables Windows Update
   - Configures autologin (password via environment variable or secure input)
   - Hardens security settings
   - Configures firewall for internal network access only
   - Installs RustDesk service for remote management
   - Creates comprehensive backups and logs

2. **POS_restore.ps1** - Reversal script that:
   - Restores Windows to default configuration
   - Re-enables disabled services using backup data
   - Clears autologin credentials securely
   - Resets firewall rules
   - Removes RustDesk service

### Script Execution Pattern
- **Batch files (.bat)** serve as launchers that invoke PowerShell scripts with proper execution policy
- **PowerShell scripts (.ps1)** contain the actual implementation logic
- All scripts check for admin privileges at startup
- Comprehensive logging to `C:\POS\Logs\`
- Registry and service backups to `C:\POS\Backup\`

## Key Commands

### Testing Scripts
```powershell
# Test PowerShell syntax before committing
.\Test_Syntax.ps1

# Check for syntax errors in specific script
Get-Command -Syntax .\New POS Setup\POS_Setup.ps1
```

### Running Main Scripts
```batch
# Full POS setup (must run as administrator)
cd "New POS Setup"
.\POS_Setup.bat

# Restore system to defaults
cd "Restore PC"
.\POS_restore.bat

# Install RustDesk remote management
.\Install_RustDesk_Service.bat

# Install Epson POS printer
.\Install_Epson_Printer.bat

# Enable network sharing for internal LAN
.\Enable_Network_Sharing.bat

# Fix Settings app if disabled by POS setup
.\Enable_Settings.bat

# Set POS user password securely
.\Set_POS_Password.bat
```

### Common Development/Debugging Tasks
```powershell
# View recent setup logs
notepad "C:\POS\Logs\setup_*.log"

# View recent restore logs
notepad "C:\POS\Logs\restore_*.log"

# Check registry backups
explorer "C:\POS\Backup"

# Manually check service status
Get-Service RustDesk, wuauserv, WSearch, DiagTrack | Format-Table Name, Status, StartType

# View firewall rules created by scripts
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*POS*" -or $_.DisplayName -like "*RustDesk*"}
```

## Important Configuration Details

### Password Security
- Scripts NEVER contain hardcoded passwords
- Password sources (in priority order):
  1. Environment variable `$env:POS_PASSWORD`
  2. Interactive secure input (`Read-Host -AsSecureString`)
- Passwords cleared from memory after use
- Autologin credentials stored in registry but cleared by restore script

### Network Configuration
- Firewall configured to **block all external traffic** by default
- Internal networks allowed: `192.168.0.0/16`, `10.0.0.0/8`, `172.16.0.0/12`
- Localhost loopback always allowed
- **Whitelisted services** (allowed through firewall):
  - Python POS server ports: TCP 8001, 8002, 8003, 8004
  - RustDesk remote management
  - Chrome Remote Desktop
  - Cloudflare services (cloudflared.exe)
  - HTTPS (443), HTTP (80), DNS (53) outbound connections
- Network sharing scripts set adapter to "Private" profile for LAN environments

### RustDesk Remote Management
- Uses **Cislink pre-configured client** from `https://cislink.nl/radmin/RustDesk_Cislink_Setup.exe`
- Server address and encryption keys pre-configured
- Installed as Windows service (auto-start, runs without login)
- Install script handles download, installation, service setup, and firewall rules
- Service management: `Get-Service RustDesk`, `Start/Stop/Restart-Service RustDesk`

### Services Disabled by POS_Setup
These services are disabled for performance and to prevent interference:
- `DiagTrack` (Diagnostic Tracking)
- `SysMain` (Superfetch/memory optimization)
- `WSearch` (Windows Search)
- `OneSyncSvc` (Sync service)
- `XblGameSave` (Xbox game save)
- `WMPNetworkSvc` (Windows Media Player network sharing)
- `wuauserv` (Windows Update)

Service states are backed up to CSV before modification for accurate restoration.

## File Structure

```
├── New POS Setup/
│   ├── POS_Setup.bat              # Main setup launcher
│   ├── POS_Setup.ps1              # Main setup script
│   ├── startServer.bat            # POS application starter
│   └── APD_513_T20II_EWM.zip      # Epson printer driver (T20II)
│
├── Restore PC/
│   ├── POS_restore.bat            # Restore launcher
│   └── POS_restore.ps1            # Restore script
│
├── docs/                          # Comprehensive documentation
│   ├── RustDesk_Cislink_Version.md      # Cislink RustDesk info
│   ├── RustDesk_Service_Guide.md        # RustDesk detailed guide
│   ├── Epson_POS_Printer_Guide.md       # Printer installation guide
│   ├── SECURITY_GUIDE.md                # Security best practices
│   └── Settings修复指南.md              # Settings recovery (Chinese)
│
├── Install_RustDesk_Service.ps1   # Standalone RustDesk installer
├── Install_Epson_Printer.ps1      # Epson printer setup wizard
├── Enable_Network_Sharing.ps1     # LAN sharing configuration
├── Enable_Settings.bat            # Quick fix for disabled Settings
├── Set_POS_Password.bat           # Secure password setter
├── Test_Syntax.ps1                # Syntax validation tool
│
├── README.md                      # Project overview and quick start
├── QUICK_REFERENCE.md             # Field technician command reference
├── INDEX.md                       # Documentation index
└── TROUBLESHOOTING.md             # Common issues and solutions
```

## Critical Safety Rules

### When Modifying Scripts

1. **NEVER hardcode passwords or sensitive data** in scripts
2. **ALWAYS test in a VM or test environment** before deploying to production
3. **ALWAYS create backups** before making registry or service changes
4. **Validate admin privileges** at script start
5. **Handle errors gracefully** - use try/catch blocks
6. **Clear sensitive data** from memory after use (`$Password = $null; [System.GC]::Collect()`)
7. **Update Test_Syntax.ps1** to validate new scripts

### Registry Operations
- Always use `/f` flag carefully (forces without prompt)
- Backup before modifications: `reg export "path" "backup.reg"`
- Use full paths: `HKLM\SOFTWARE\...` not abbreviated forms
- Test registry operations on isolated keys first

### Service Management
- Check service exists before operations: `Get-Service -Name $svc -ErrorAction SilentlyContinue`
- Record original state before modifications
- Use `-ErrorAction SilentlyContinue` when services might not exist
- Verify service state after changes

### Firewall Rules
- Always specify both direction and action explicitly
- Use unique, descriptive rule names (e.g., "POS Internal Inbound - 192.168.0.0/16")
- Delete old rules before adding new ones to avoid duplicates
- Test connectivity after firewall changes

## Documentation Conventions

- **README.md** - Entry point, project overview, quick start
- **QUICK_REFERENCE.md** - Field technician one-page reference for common tasks
- **INDEX.md** - Navigation hub for all documentation
- **TROUBLESHOOTING.md** - Structured problem/solution reference
- **docs/** - Detailed guides for specific components
- All user-facing documentation is in Chinese and Dutch (Dutch for employer "Yongka")
- Code comments in English, user messages can be mixed

## Common Troubleshooting Context

### Settings App Disabled
After running POS_Setup, Settings and Control Panel are intentionally disabled via:
```
HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoControlPanel = 1
```
**Solution**: Run `Enable_Settings.bat` to re-enable

### Network Sharing Not Working
Requires:
1. Network profile set to "Private" (not "Public")
2. Firewall rules for "Network Discovery" and "File and Printer Sharing" enabled
3. Services running: FDResPub, SSDPSRV, upnphost
4. SMB2/3 enabled (SMB1 should be disabled)

**Solution**: Run `Enable_Network_Sharing.bat`

### Epson Printer Setup
- Requires APD6 (Advanced Printer Driver 6) installed first
- Supports USB and network (TCP/IP) connections
- Network printers use port 9100 by default
- Models: TM-T20/T20II/T20III/T20X, TM-M30/M30II/M30III, TM-T88V/T88VI

## Testing Checklist

Before committing changes to setup scripts:
- [ ] Run `Test_Syntax.ps1` on all modified .ps1 files
- [ ] Test in Windows 11 VM with snapshot
- [ ] Verify backup creation (registry + service CSV)
- [ ] Verify logging to C:\POS\Logs\
- [ ] Test restore script to validate reversibility
- [ ] Check that no sensitive data is logged
- [ ] Verify firewall rules don't break connectivity
- [ ] Test RustDesk service starts and accepts connections
- [ ] Confirm autologin works (if configured)
- [ ] Verify Settings can be re-enabled via Enable_Settings.bat

## Git Workflow

Current branch: `master` (also main branch for PRs)

Recent commits show focus on:
- Cislink-specific RustDesk configuration
- Epson printer installation automation
- Network sharing setup
- Documentation improvements (Chinese/Dutch/English)

When committing:
- Use clear, descriptive commit messages
- Include emoji prefixes (🔥, 🖨️, ✨, 🔗, etc.) matching existing style
- Test thoroughly in isolated environment first
- Update relevant documentation files
- Keep README.md and QUICK_REFERENCE.md in sync with script changes
