@echo off
echo ================================================
echo   POS Kiosk Mode 配置工具
echo ================================================
echo.

PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0Enable_Kiosk_Mode.ps1'"

pause
