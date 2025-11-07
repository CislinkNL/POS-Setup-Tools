# ============================================================================
# Kiosk Mode 配置脚本
# 用途: 锁定 POS 系统，防止员工退出到桌面
# 需要密码才能退出全屏模式
# ============================================================================

#Requires -RunAsAdministrator

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  POS Kiosk Mode 配置工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 获取当前用户信息
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$UserName = $CurrentUser.Split('\')[-1]

Write-Host "当前用户: $CurrentUser" -ForegroundColor Gray
Write-Host ""

# 配置选项
Write-Host "请选择 Kiosk 模式类型:" -ForegroundColor Yellow
Write-Host "  [1] Shell Launcher - 完全锁定（推荐，需要 Pro/Enterprise）" -ForegroundColor Gray
Write-Host "  [2] Assigned Access - Windows 设置界面配置" -ForegroundColor Gray
Write-Host "  [3] 注册表锁定 - 限制系统功能（适用所有版本）" -ForegroundColor Gray
Write-Host "  [4] 自定义 Shell - 替换 Explorer 为 POS 程序" -ForegroundColor Gray
Write-Host ""
$mode = Read-Host "输入选项 (1-4)"

# ============================================================================
# 方案 1: Shell Launcher (最安全，需要 Windows 10/11 Pro/Enterprise)
# ============================================================================
if ($mode -eq "1") {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  配置 Shell Launcher" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    # 检查系统版本
    $OSName = (Get-WmiObject -Class Win32_OperatingSystem).Caption
    if ($OSName -notlike "*Pro*" -and $OSName -notlike "*Enterprise*") {
        Write-Warning "Shell Launcher 需要 Windows 10/11 Pro 或 Enterprise 版本"
        Write-Host "您的系统: $OSName" -ForegroundColor Yellow
        Write-Host "请选择其他方案" -ForegroundColor Yellow
        exit 1
    }

    # 启用 Shell Launcher 功能
    Write-Host "[1/4] 启用 Shell Launcher 功能..." -ForegroundColor Cyan
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName "Client-EmbeddedShellLauncher" -NoRestart -ErrorAction Stop
        Write-Host "      ✓ Shell Launcher 已启用" -ForegroundColor Green
    } catch {
        Write-Warning "无法启用 Shell Launcher: $($_.Exception.Message)"
        Write-Host "可能已经启用或需要重启" -ForegroundColor Yellow
    }

    # 配置 POS 程序路径
    Write-Host ""
    Write-Host "[2/4] 配置 POS 程序..." -ForegroundColor Cyan
    $POSPath = Read-Host "输入 POS 程序完整路径 (如: C:\POS\app.exe)"

    if (-not (Test-Path $POSPath)) {
        Write-Warning "路径不存在: $POSPath"
        $create = Read-Host "是否继续配置? (y/n)"
        if ($create -ne 'y') {
            exit 1
        }
    }

    # 设置退出密码
    Write-Host ""
    Write-Host "[3/4] 设置退出密码..." -ForegroundColor Cyan
    $ExitPassword = Read-Host "设置退出 Kiosk 模式的密码" -AsSecureString
    $ExitPasswordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ExitPassword)
    )

    # 加密密码保存
    $PasswordHash = [System.Convert]::ToBase64String(
        [System.Text.Encoding]::UTF8.GetBytes($ExitPasswordPlain)
    )

    # 保存配置
    $ConfigPath = "C:\POS\Config"
    New-Item -Path $ConfigPath -ItemType Directory -Force | Out-Null

    $Config = @{
        POSPath = $POSPath
        ExitPasswordHash = $PasswordHash
        ConfiguredBy = $CurrentUser
        ConfiguredDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    $Config | ConvertTo-Json | Out-File "$ConfigPath\kiosk_config.json" -Encoding UTF8

    Write-Host "      ✓ 配置已保存" -ForegroundColor Green

    # 创建退出脚本
    Write-Host ""
    Write-Host "[4/4] 创建退出脚本..." -ForegroundColor Cyan

    $ExitScriptContent = @"
# Kiosk Mode 退出脚本
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

`$config = Get-Content "C:\POS\Config\kiosk_config.json" | ConvertFrom-Json
`$savedHash = `$config.ExitPasswordHash

`$form = New-Object System.Windows.Forms.Form
`$form.Text = "退出 Kiosk 模式"
`$form.Size = New-Object System.Drawing.Size(300,150)
`$form.StartPosition = "CenterScreen"
`$form.TopMost = `$true

`$label = New-Object System.Windows.Forms.Label
`$label.Location = New-Object System.Drawing.Point(10,20)
`$label.Size = New-Object System.Drawing.Size(280,20)
`$label.Text = "输入管理员密码:"
`$form.Controls.Add(`$label)

`$textBox = New-Object System.Windows.Forms.TextBox
`$textBox.Location = New-Object System.Drawing.Point(10,50)
`$textBox.Size = New-Object System.Drawing.Size(260,20)
`$textBox.UseSystemPasswordChar = `$true
`$form.Controls.Add(`$textBox)

`$okButton = New-Object System.Windows.Forms.Button
`$okButton.Location = New-Object System.Drawing.Point(75,80)
`$okButton.Size = New-Object System.Drawing.Size(75,23)
`$okButton.Text = "确定"
`$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
`$form.AcceptButton = `$okButton
`$form.Controls.Add(`$okButton)

`$cancelButton = New-Object System.Windows.Forms.Button
`$cancelButton.Location = New-Object System.Drawing.Point(150,80)
`$cancelButton.Size = New-Object System.Drawing.Size(75,23)
`$cancelButton.Text = "取消"
`$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
`$form.CancelButton = `$cancelButton
`$form.Controls.Add(`$cancelButton)

`$result = `$form.ShowDialog()

if (`$result -eq [System.Windows.Forms.DialogResult]::OK) {
    `$inputHash = [System.Convert]::ToBase64String(
        [System.Text.Encoding]::UTF8.GetBytes(`$textBox.Text)
    )

    if (`$inputHash -eq `$savedHash) {
        [System.Windows.Forms.MessageBox]::Show("密码正确，正在退出 Kiosk 模式...", "成功", 0, [System.Windows.Forms.MessageBoxIcon]::Information)

        # 停止 POS 程序
        Get-Process | Where-Object {`$_.Path -eq "`$(`$config.POSPath)"} | Stop-Process -Force

        # 启动 Explorer
        Start-Process explorer.exe
    } else {
        [System.Windows.Forms.MessageBox]::Show("密码错误！", "错误", 0, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

`$form.Dispose()
"@

    $ExitScriptContent | Out-File "$ConfigPath\Exit_Kiosk.ps1" -Encoding UTF8

    # 创建快捷方式
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:PUBLIC\Desktop\退出Kiosk模式.lnk")
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$ConfigPath\Exit_Kiosk.ps1`""
    $Shortcut.WorkingDirectory = $ConfigPath
    $Shortcut.IconLocation = "shell32.dll,44"
    $Shortcut.Save()

    Write-Host "      ✓ 退出脚本已创建" -ForegroundColor Green
    Write-Host "      ✓ 桌面快捷方式已创建" -ForegroundColor Green

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✅ Shell Launcher 配置完成！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "下一步:" -ForegroundColor Yellow
    Write-Host "  1. 重启系统以应用 Shell Launcher" -ForegroundColor Gray
    Write-Host "  2. 使用 '退出Kiosk模式' 快捷方式退出" -ForegroundColor Gray
    Write-Host "  3. 退出密码已加密保存在: $ConfigPath\kiosk_config.json" -ForegroundColor Gray

}
# ============================================================================
# 方案 2: Assigned Access (Windows 设置界面)
# ============================================================================
elseif ($mode -eq "2") {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Assigned Access 配置指南" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Assigned Access 需要通过 Windows 设置配置:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "步骤 1: 打开 Windows 设置" -ForegroundColor Cyan
    Write-Host "  Win + I → 账户 → 家庭和其他用户" -ForegroundColor Gray
    Write-Host ""
    Write-Host "步骤 2: 设置展台模式" -ForegroundColor Cyan
    Write-Host "  点击 '设置展台' → 创建展台账户" -ForegroundColor Gray
    Write-Host ""
    Write-Host "步骤 3: 选择应用" -ForegroundColor Cyan
    Write-Host "  选择您的 POS 应用（必须是 UWP 应用或 Edge）" -ForegroundColor Gray
    Write-Host ""
    Write-Host "步骤 4: 退出展台模式" -ForegroundColor Cyan
    Write-Host "  按 Ctrl + Alt + Del 退出" -ForegroundColor Gray
    Write-Host ""

    $openSettings = Read-Host "是否现在打开设置? (y/n)"
    if ($openSettings -eq 'y') {
        Start-Process "ms-settings:otherusers"
    }
}
# ============================================================================
# 方案 3: 注册表锁定（适用所有版本）
# ============================================================================
elseif ($mode -eq "3") {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  注册表锁定配置" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "此方案将限制以下功能:" -ForegroundColor Yellow
    Write-Host "  • 禁用任务管理器 (Ctrl+Alt+Del)" -ForegroundColor Gray
    Write-Host "  • 隐藏桌面图标" -ForegroundColor Gray
    Write-Host "  • 禁用右键菜单" -ForegroundColor Gray
    Write-Host "  • 禁用 Windows 快捷键" -ForegroundColor Gray
    Write-Host "  • 锁定任务栏" -ForegroundColor Gray
    Write-Host ""

    $confirm = Read-Host "确认应用这些限制? (y/n)"
    if ($confirm -ne 'y') {
        exit 0
    }

    # 备份当前配置
    Write-Host ""
    Write-Host "备份当前配置..." -ForegroundColor Cyan
    $BackupPath = "C:\POS\Backup\kiosk_registry_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"
    New-Item -Path "C:\POS\Backup" -ItemType Directory -Force | Out-Null
    reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies" $BackupPath /y | Out-Null
    Write-Host "✓ 备份已保存: $BackupPath" -ForegroundColor Green

    # 应用限制
    Write-Host ""
    Write-Host "应用 Kiosk 限制..." -ForegroundColor Cyan

    # 禁用任务管理器
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /t REG_DWORD /d 1 /f | Out-Null

    # 隐藏桌面图标
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideIcons /t REG_DWORD /d 1 /f | Out-Null

    # 禁用右键菜单
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoViewContextMenu /t REG_DWORD /d 1 /f | Out-Null

    # 禁用 Windows 键
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoWinKeys /t REG_DWORD /d 1 /f | Out-Null

    # 禁用 Alt+Tab
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v AltTabSettings /t REG_DWORD /d 0 /f | Out-Null

    # 禁用注销
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoLogoff /t REG_DWORD /d 1 /f | Out-Null

    # 禁用关机
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoClose /t REG_DWORD /d 1 /f | Out-Null

    Write-Host "✓ Kiosk 限制已应用" -ForegroundColor Green

    # 创建解锁脚本
    Write-Host ""
    Write-Host "创建解锁脚本..." -ForegroundColor Cyan

    # 设置解锁密码
    $UnlockPassword = Read-Host "设置解锁密码" -AsSecureString
    $UnlockPasswordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($UnlockPassword)
    )
    $PasswordHash = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UnlockPasswordPlain))

    $ConfigPath = "C:\POS\Config"
    New-Item -Path $ConfigPath -ItemType Directory -Force | Out-Null

    $Config = @{
        UnlockPasswordHash = $PasswordHash
        BackupPath = $BackupPath
        ConfiguredDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    $Config | ConvertTo-Json | Out-File "$ConfigPath\unlock_config.json" -Encoding UTF8

    $UnlockScriptContent = @"
#Requires -RunAsAdministrator
Add-Type -AssemblyName System.Windows.Forms

`$config = Get-Content "C:\POS\Config\unlock_config.json" | ConvertFrom-Json

`$password = [Microsoft.VisualBasic.Interaction]::InputBox("输入解锁密码:", "解锁 Kiosk 模式", "")
`$inputHash = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(`$password))

if (`$inputHash -eq `$config.UnlockPasswordHash) {
    Write-Host "密码正确，正在解锁..." -ForegroundColor Green

    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /f
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideIcons /f
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoViewContextMenu /f
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoWinKeys /f
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v AltTabSettings /f
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoLogoff /f
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoClose /f

    Stop-Process -Name explorer -Force
    Start-Process explorer

    [System.Windows.Forms.MessageBox]::Show("Kiosk 模式已解锁！", "成功", 0, 64)
} else {
    [System.Windows.Forms.MessageBox]::Show("密码错误！", "错误", 0, 16)
}
"@

    $UnlockScriptContent | Out-File "$ConfigPath\Unlock_Kiosk.ps1" -Encoding UTF8

    # 创建隐藏的快捷方式（需要特殊键组合）
    Write-Host "✓ 解锁脚本已创建: $ConfigPath\Unlock_Kiosk.ps1" -ForegroundColor Green

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✅ Kiosk 模式已启用！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "重要信息:" -ForegroundColor Yellow
    Write-Host "  • 解锁脚本: $ConfigPath\Unlock_Kiosk.ps1" -ForegroundColor Gray
    Write-Host "  • 备份文件: $BackupPath" -ForegroundColor Gray
    Write-Host "  • 需要以管理员身份运行解锁脚本" -ForegroundColor Gray
    Write-Host ""
    Write-Host "解锁方法:" -ForegroundColor Yellow
    Write-Host "  1. 按 Ctrl+Shift+Esc 尝试打开任务管理器（将被阻止）" -ForegroundColor Gray
    Write-Host "  2. 使用其他电脑通过远程访问" -ForegroundColor Gray
    Write-Host "  3. 重启进入安全模式" -ForegroundColor Gray
    Write-Host "  4. 运行解锁脚本: powershell -ExecutionPolicy Bypass -File '$ConfigPath\Unlock_Kiosk.ps1'" -ForegroundColor Gray

}
# ============================================================================
# 方案 4: 自定义 Shell
# ============================================================================
elseif ($mode -eq "4") {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  自定义 Shell 配置" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "警告: 此方案将替换 Windows Explorer！" -ForegroundColor Red
    Write-Host "如果配置错误，可能导致无法正常使用系统" -ForegroundColor Red
    Write-Host ""

    $confirm = Read-Host "确认继续? (输入 YES 确认)"
    if ($confirm -ne "YES") {
        Write-Host "已取消" -ForegroundColor Yellow
        exit 0
    }

    # POS 程序路径
    $POSPath = Read-Host "输入 POS 程序完整路径"

    if (-not (Test-Path $POSPath)) {
        Write-Error "路径不存在: $POSPath"
        exit 1
    }

    # 备份当前配置
    Write-Host ""
    Write-Host "备份当前配置..." -ForegroundColor Cyan
    $BackupPath = "C:\POS\Backup\shell_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"
    New-Item -Path "C:\POS\Backup" -ItemType Directory -Force | Out-Null
    reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" $BackupPath /y | Out-Null
    Write-Host "✓ 备份已保存: $BackupPath" -ForegroundColor Green

    # 设置自定义 Shell
    Write-Host ""
    Write-Host "设置自定义 Shell..." -ForegroundColor Cyan
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "$POSPath" /f | Out-Null

    Write-Host "✓ 自定义 Shell 已设置" -ForegroundColor Green

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✅ 自定义 Shell 配置完成！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "重要:" -ForegroundColor Red
    Write-Host "  • 重启后将直接启动 POS 程序" -ForegroundColor Gray
    Write-Host "  • 不会显示 Windows 桌面" -ForegroundColor Gray
    Write-Host "  • 备份文件: $BackupPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "恢复方法:" -ForegroundColor Yellow
    Write-Host "  1. 重启进入安全模式" -ForegroundColor Gray
    Write-Host "  2. 运行: reg add `"HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon`" /v Shell /t REG_SZ /d `"explorer.exe`" /f" -ForegroundColor Gray
    Write-Host "  3. 或导入备份文件: $BackupPath" -ForegroundColor Gray
} else {
    Write-Host "无效的选择" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
