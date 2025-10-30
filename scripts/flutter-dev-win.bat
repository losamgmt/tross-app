@echo off
REM Flutter Web Development Start Script
REM Handles Windows-specific Chrome debugging issues

echo.
echo ====================================
echo   TrossApp Frontend Development
echo ====================================
echo.

REM Check if we're in the correct directory
if not exist "frontend" (
    echo ❌ Error: frontend directory not found
    echo    Run this script from the project root
    exit /b 1
)

REM Kill any existing Chrome processes to prevent connection issues
echo 🧹 Cleaning up existing Chrome processes...
taskkill /F /IM chrome.exe >nul 2>&1
timeout /t 2 /nobreak >nul

REM Clean Flutter build cache
echo 🧹 Cleaning Flutter build cache...
cd frontend
if exist "build" rmdir /s /q build 2>nul
if exist ".dart_tool" rmdir /s /q .dart_tool 2>nul

REM Get pub packages
echo 📦 Getting dependencies...
call flutter pub get

echo.
echo 🚀 Starting Flutter app on Chrome...
echo    URL: http://localhost:8080
echo    Press Ctrl+C to stop
echo.

REM Use --web-renderer html for better Windows compatibility
REM Disable debug service to avoid hanging
echo Starting Flutter Web with Windows-optimized settings...
echo Using profile mode (debug service issue workaround)
echo.
cd /d "%~dp0..\frontend"
flutter run -d chrome --web-port=8080 --profile

cd ..
