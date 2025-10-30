@echo off
REM Port Consistency Fix Script for Windows
REM Run this after reboot to fix all port references
REM Usage: scripts\fix-ports.bat

echo.
echo ========================================
echo  TrossApp Port Consistency Fix
echo ========================================
echo.

cd /d "%~dp0.."

echo Fixing port references across TrossApp...
echo.

REM Fix scripts/kill-port.js
echo [1/9] Fixing scripts/kill-port.js...
powershell -Command "(Get-Content scripts/kill-port.js) -replace '3001 3000 5173', '3001 8080' | Set-Content scripts/kill-port.js"

REM Fix scripts/check-ports.js
echo [2/9] Fixing scripts/check-ports.js...
powershell -Command "(Get-Content scripts/check-ports.js) -replace '3001 3000 5173', '3001 8080' | Set-Content scripts/check-ports.js"

REM Fix scripts/start-dev.bat
echo [3/9] Fixing scripts/start-dev.bat...
powershell -Command "(Get-Content scripts/start-dev.bat) -replace '5173', '8080' | Set-Content scripts/start-dev.bat"

REM Fix scripts/README.md
echo [4/9] Fixing scripts/README.md...
powershell -Command "(Get-Content scripts/README.md) -replace '5173', '8080' | Set-Content scripts/README.md"

REM Fix docs - port 3000 to 3001
echo [5/9] Fixing documentation (3000 to 3001)...
powershell -Command "Get-ChildItem -Path docs -Filter *.md -Recurse | ForEach-Object { (Get-Content $_.FullName) -replace ':3000', ':3001' | Set-Content $_.FullName }"

REM Fix docs - port 5173 to 8080
echo [6/9] Fixing documentation (5173 to 8080)...
powershell -Command "Get-ChildItem -Path docs -Filter *.md -Recurse | ForEach-Object { (Get-Content $_.FullName) -replace '5173', '8080' | Set-Content $_.FullName }"

REM Fix FLUTTER_WEB_TROUBLESHOOTING.md
echo [7/9] Fixing FLUTTER_WEB_TROUBLESHOOTING.md (8081 to 8080)...
powershell -Command "(Get-Content FLUTTER_WEB_TROUBLESHOOTING.md) -replace '8081', '8080' | Set-Content FLUTTER_WEB_TROUBLESHOOTING.md"

REM Fix backend/scripts/export-openapi.js
echo [8/9] Fixing backend/scripts/export-openapi.js...
powershell -Command "(Get-Content backend/scripts/export-openapi.js) -replace ':3000', ':3001' | Set-Content backend/scripts/export-openapi.js"

REM Fix docs/PROCESS_MANAGEMENT.md specifically
echo [9/9] Fixing docs/PROCESS_MANAGEMENT.md...
powershell -Command "(Get-Content docs/PROCESS_MANAGEMENT.md) -replace '5173', '8080' | Set-Content docs/PROCESS_MANAGEMENT.md"

echo.
echo ========================================
echo  ✅ All port references fixed!
echo ========================================
echo.
echo Port Configuration:
echo    Backend:  3001
echo    Frontend: 8080
echo    DB Dev:   5432
echo    DB Test:  5433
echo    Redis:    6379
echo.
echo Test with: npm run ports:check
echo Start with: npm run dev:backend
echo             npm run dev:frontend
echo.
pause
