@echo off
REM Simple Flutter cleanup script for Windows
echo 🧹 Cleaning Flutter build cache...
cd frontend 2>nul || (echo ❌ frontend directory not found && exit /b 1)

REM Force remove build directories
rmdir /s /q build 2>nul
rmdir /s /q .dart_tool 2>nul

REM Deep clean option
if "%1"=="--deep" del /f /q pubspec.lock 2>nul

echo ✅ Flutter cleanup completed