@echo off
REM ===============================================
REM  Install_RustDesk_Service.bat
REM  RustDesk 服务安装启动器
REM ===============================================

echo ================================================
echo   RustDesk 服务安装工具
echo ================================================
echo.
echo 此脚本将安装并配置 RustDesk 为 Windows 服务
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

REM 运行 PowerShell 脚本
powershell -ExecutionPolicy Bypass -File "%~dp0Install_RustDesk_Service.ps1"

echo.
pause
