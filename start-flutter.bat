@echo off
echo ====================================================
echo   Starting Shaadi Setu Flutter Mobile App (Dual Mode)
echo ====================================================

REM Reverse port 8080 so connected Android phone can reach backend at localhost:8080
if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
    echo Forwarding backend port 8080 to connected Android device...
    "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" reverse tcp:8080 tcp:8080 2>nul
)

cd /d "%~dp0mobile-app"
call flutter run
pause
