@echo off
REM ============================================================================
REM 启用内网文件共享和网络发现 - 批处理启动器
REM ============================================================================

echo.
echo ========================================
echo   启用内网文件共享和网络发现
echo ========================================
echo.

REM 检查管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] 需要管理员权限
    echo.
    echo 请右键点击此文件，选择"以管理员身份运行"
    echo.
    pause
    exit /b 1
)

REM 运行 PowerShell 脚本
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Enable_Network_Sharing.ps1"

exit /b %errorlevel%
