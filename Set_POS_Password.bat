@echo off
REM ===============================================
REM  Set_POS_Password.bat
REM  安全设置 POS 系统密码的辅助脚本
REM  用于在运行主脚本前设置环境变量
REM ===============================================

echo ================================================
echo   POS Password Setup Helper
echo ================================================
echo.
echo This script will help you securely set the password
echo for POS system auto-login configuration.
echo.
echo The password will be stored in environment variable
echo and automatically cleared after use.
echo.

:input_password
set /p "password=Enter password for user 'Beheer': "
if "%password%"=="" (
    echo Error: Password cannot be empty!
    goto input_password
)

REM 验证密码长度
set "temp=%password%"
set "count=0"
:count_loop
if defined temp (
    set "temp=%temp:~1%"
    set /a count+=1
    goto count_loop
)

if %count% LSS 8 (
    echo Warning: Password is less than 8 characters.
    echo Recommend using a stronger password for security.
    set /p "continue=Continue anyway? (y/N): "
    if /i not "%continue%"=="y" goto input_password
)

REM 设置环境变量
set "POS_PASSWORD=%password%"

echo.
echo ✓ Password set successfully in environment variable.
echo ✓ You can now run POS_Setup.ps1
echo.
echo Note: The password will be automatically cleared after script execution.
echo.

pause

REM 清除本地变量
set "password="
set "temp="
set "count="
set "continue="