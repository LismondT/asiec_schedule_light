@echo off
chcp 65001 >nul
echo.
echo 🏫 College Schedule Builder
echo ===========================
powershell -ExecutionPolicy Bypass -File "build_all.ps1"
echo.
pause