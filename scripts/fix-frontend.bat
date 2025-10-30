@echo off
REM Quick Frontend Troubleshooting Script
REM Run this if the frontend hangs or won't start

echo.
echo ============================================
echo   TrossApp Frontend Troubleshooting
echo ============================================
echo.

echo [1/5] Killing Chrome processes...
taskkill /F /IM chrome.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Chrome processes killed
) else (
    echo ℹ️  No Chrome processes found
)
timeout /t 1 /nobreak >nul

echo.
echo [2/5] Checking if port 8080 is in use...
netstat -ano | findstr :8080 >nul
if %errorlevel% equ 0 (
    echo ⚠️  Port 8080 is in use! Attempting to free it...
    node scripts/kill-port.js 8080
) else (
    echo ✅ Port 8080 is available
)

echo.
echo [3/5] Cleaning Flutter build cache...
cd frontend
if exist "build" (
    rmdir /s /q build 2>nul
    echo ✅ Deleted build directory
)
if exist ".dart_tool" (
    rmdir /s /q .dart_tool 2>nul
    echo ✅ Deleted .dart_tool directory
)
if exist "windows\flutter\ephemeral" (
    rmdir /s /q windows\flutter\ephemeral 2>nul
    echo ✅ Deleted ephemeral directory
)

echo.
echo [4/5] Getting fresh dependencies...
call flutter pub get >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Dependencies updated
) else (
    echo ❌ Failed to get dependencies
)

echo.
echo [5/5] Checking Flutter doctor...
call flutter doctor --version
cd ..

echo.
echo ============================================
echo   Troubleshooting Complete
echo ============================================
echo.
echo 💡 Try running: npm run dev:frontend:win
echo.
pause
