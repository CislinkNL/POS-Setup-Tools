@echo off
REM ===============================================
REM  Enable_Settings.bat
REM  快速修复：重新启用 Windows Settings 和控制面板
REM  使用场景：运行 POS Setup 后无法打开设置
REM ===============================================

echo ================================================
echo   重新启用 Windows Settings 和控制面板
echo ================================================
echo.
echo 此脚本将恢复对 Windows 设置和控制面板的访问权限
echo.

REM 检查管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] 需要管理员权限！
    echo 请右键点击此文件，选择"以管理员身份运行"
    echo.
    pause
    exit /b 1
)

echo [1/3] 正在删除设置访问限制...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoControlPanel /f >nul 2>&1
if %errorLevel% equ 0 (
    echo      ✓ 用户级别限制已移除
) else (
    echo      - 用户级别无限制或已移除
)

reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v SettingsPageVisibility /f >nul 2>&1
if %errorLevel% equ 0 (
    echo      ✓ 系统级别限制已移除
) else (
    echo      - 系统级别无限制或已移除
)

echo.
echo [2/3] 正在重启 Windows Explorer...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 2 /nobreak >nul
start explorer.exe

echo      ✓ Explorer 已重启
echo.
echo [3/3] 验证更改...
timeout /t 2 /nobreak >nul

echo.
echo ================================================
echo   ✓ 完成！
echo ================================================
echo.
echo Windows Settings 和控制面板已重新启用
echo.
echo 您现在可以：
echo   • 使用 Win + I 打开设置
echo   • 从开始菜单点击"设置"
echo   • 使用 Win + X 访问控制面板
echo.
echo 注意：如果仍无法打开，请尝试重启计算机
echo.

pause
