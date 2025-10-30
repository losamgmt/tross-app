@echo off
REM ================================================================
REM NUCLEAR CLEANUP - Use before reboot or when things are broken
REM ================================================================

echo.
echo ═══════════════════════════════════════════════════════════
echo    TROSSAPP NUCLEAR CLEANUP
echo ═══════════════════════════════════════════════════════════
echo.

REM Step 1: Kill all processes
echo [1/6] Killing all Chrome processes...
taskkill /F /IM chrome.exe /T >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo       ✓ Chrome killed
) else (
    echo       ℹ No Chrome processes found
)

echo [2/6] Killing all Dart/Flutter processes...
taskkill /F /IM dart.exe /T >nul 2>&1
taskkill /F /IM flutter.exe /T >nul 2>&1
echo       ✓ Dart/Flutter killed

echo [3/6] Killing Node processes on ports 3001 and 8080...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3001 ^| findstr LISTENING') do (
    taskkill /F /PID %%a >nul 2>&1
)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080 ^| findstr LISTENING') do (
    taskkill /F /PID %%a >nul 2>&1
)
echo       ✓ Port processes killed

REM Step 2: Clean Flutter cache
echo [4/6] Cleaning Flutter cache...
cd /d "%~dp0..\frontend"
if exist "build" (
    rmdir /s /q build >nul 2>&1
    echo       ✓ Removed build/
)
if exist ".dart_tool" (
    rmdir /s /q .dart_tool >nul 2>&1
    echo       ✓ Removed .dart_tool/
)
if exist "windows\flutter\ephemeral" (
    rmdir /s /q windows\flutter\ephemeral >nul 2>&1
    echo       ✓ Removed ephemeral/
)

REM Step 3: Clean Node modules cache
echo [5/6] Cleaning Node cache...
cd /d "%~dp0.."
rmdir /s /q node_modules\.cache >nul 2>&1
cd backend
rmdir /s /q node_modules\.cache >nul 2>&1
echo       ✓ Node cache cleaned

REM Step 4: Stop Docker containers
echo [6/6] Stopping Docker containers...
cd /d "%~dp0.."
docker-compose down >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo       ✓ Docker containers stopped
) else (
    echo       ℹ Docker not running or error stopping
)

echo.
echo ═══════════════════════════════════════════════════════════
echo    CLEANUP COMPLETE
echo ═══════════════════════════════════════════════════════════
echo.
echo Next steps after reboot:
echo   1. Start Docker:  docker-compose up -d
echo   2. Start Backend: npm run dev:backend
echo   3. Start Frontend: cd frontend ^&^& flutter run -d chrome --web-port=8080 --profile
echo.
echo See docs/POST_REBOOT_CHECKLIST.md for detailed instructions.
echo.
pause
