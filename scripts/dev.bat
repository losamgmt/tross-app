@echo off
REM TrossApp Development Startup Script for Windows
REM Handles clean startup and common development tasks

echo 🚀 TrossApp Development Environment Setup
echo ==========================================

REM Check if we're in the right directory
if not exist package.json (
    echo ❌ Please run this script from the project root directory
    exit /b 1
)

if "%1"=="backend" goto start_backend
if "%1"=="frontend" goto start_frontend
if "%1"=="clean" goto clean_env
if "%1"=="help" goto show_help

:start_full
echo Starting full development environment...
call :start_backend_service
call :show_urls
echo Backend running. Press any key to start Flutter...
pause >nul
call :start_frontend_service
goto end

:start_backend
call :start_backend_service
call :show_urls
echo Backend only mode. Frontend can be started separately.
goto end

:start_frontend
call :start_frontend_service
goto end

:clean_env
echo 🧹 Cleaning development environment...
cd frontend
flutter clean
rmdir /s /q build 2>nul
cd ..\backend
rmdir /s /q node_modules\.cache 2>nul
echo ✅ Cleanup complete
goto end

:show_help
echo Usage: %0 [command]
echo Commands:
echo   start    - Start both backend and frontend (default)
echo   backend  - Start only backend
echo   frontend - Start only frontend
echo   clean    - Clean build caches
echo   help     - Show this help
goto end

:start_backend_service
echo 🔧 Starting backend server...
cd backend

REM Check if backend is already running
netstat -ano | findstr ":3001" >nul
if %errorlevel% == 0 (
    echo ✅ Backend already running on port 3001
) else (
    echo Starting Node.js backend...
    start "TrossApp Backend" cmd /k "npm start"
    timeout /t 3 /nobreak >nul
    
    netstat -ano | findstr ":3001" >nul
    if %errorlevel% == 0 (
        echo ✅ Backend started successfully on port 3001
    ) else (
        echo ❌ Backend failed to start
        exit /b 1
    )
)
cd ..
exit /b 0

:start_frontend_service
echo 📱 Starting Flutter frontend...
cd frontend

echo 🧹 Cleaning Flutter build cache...
flutter clean
rmdir /s /q build 2>nul

echo 📦 Getting Flutter dependencies...
flutter pub get

echo 🚀 Starting Flutter app...
flutter run --web-browser-flag "--disable-web-security"

cd ..
exit /b 0

:show_urls
echo.
echo 📍 Development URLs:
echo    Backend API: http://localhost:3001/api/health
echo    Dev Status:  http://localhost:3001/api/dev/status
echo    Flutter App: (will open automatically in browser)
echo.
exit /b 0

:end