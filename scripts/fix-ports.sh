#!/bin/bash
# Port Consistency Fix Script
# Run this after reboot to fix all port references
# Usage: bash scripts/fix-ports.sh

echo "🔧 Fixing port references across TrossApp..."
echo ""

# Fix scripts/kill-port.js
echo "📝 Fixing scripts/kill-port.js..."
sed -i 's/3001 3000 5173/3001 8080/g' scripts/kill-port.js 2>/dev/null || \
  powershell -Command "(Get-Content scripts/kill-port.js) -replace '3001 3000 5173', '3001 8080' | Set-Content scripts/kill-port.js"

# Fix scripts/check-ports.js
echo "📝 Fixing scripts/check-ports.js..."
sed -i 's/3001 3000 5173/3001 8080/g' scripts/check-ports.js 2>/dev/null || \
  powershell -Command "(Get-Content scripts/check-ports.js) -replace '3001 3000 5173', '3001 8080' | Set-Content scripts/check-ports.js"

# Fix scripts/start-dev.bat
echo "📝 Fixing scripts/start-dev.bat..."
sed -i 's/5173/8080/g' scripts/start-dev.bat 2>/dev/null || \
  powershell -Command "(Get-Content scripts/start-dev.bat) -replace '5173', '8080' | Set-Content scripts/start-dev.bat"

# Fix scripts/README.md
echo "📝 Fixing scripts/README.md..."
sed -i 's/5173/8080/g' scripts/README.md 2>/dev/null || \
  powershell -Command "(Get-Content scripts/README.md) -replace '5173', '8080' | Set-Content scripts/README.md"

# Fix docs - port 3000 to 3001
echo "📝 Fixing documentation (3000 → 3001)..."
find docs -name "*.md" -exec sed -i 's/:3000/:3001/g' {} \; 2>/dev/null || \
  powershell -Command "Get-ChildItem -Path docs -Filter *.md -Recurse | ForEach-Object { (Get-Content \$_.FullName) -replace ':3000', ':3001' | Set-Content \$_.FullName }"

# Fix docs - port 5173 to 8080  
echo "📝 Fixing documentation (5173 → 8080)..."
find docs -name "*.md" -exec sed -i 's/5173/8080/g' {} \; 2>/dev/null || \
  powershell -Command "Get-ChildItem -Path docs -Filter *.md -Recurse | ForEach-Object { (Get-Content \$_.FullName) -replace '5173', '8080' | Set-Content \$_.FullName }"

# Fix FLUTTER_WEB_TROUBLESHOOTING.md
echo "📝 Fixing FLUTTER_WEB_TROUBLESHOOTING.md (8081 → 8080)..."
sed -i 's/8081/8080/g' FLUTTER_WEB_TROUBLESHOOTING.md 2>/dev/null || \
  powershell -Command "(Get-Content FLUTTER_WEB_TROUBLESHOOTING.md) -replace '8081', '8080' | Set-Content FLUTTER_WEB_TROUBLESHOOTING.md"

# Fix backend/scripts/export-openapi.js
echo "📝 Fixing backend/scripts/export-openapi.js..."
sed -i 's/:3000/:3001/g' backend/scripts/export-openapi.js 2>/dev/null || \
  powershell -Command "(Get-Content backend/scripts/export-openapi.js) -replace ':3000', ':3001' | Set-Content backend/scripts/export-openapi.js"

echo ""
echo "✅ All port references fixed!"
echo ""
echo "📊 Port Configuration:"
echo "   Backend:  3001"
echo "   Frontend: 8080"
echo "   DB Dev:   5432"
echo "   DB Test:  5433"
echo "   Redis:    6379"
echo ""
echo "🧪 Test with: npm run ports:check"
echo "🚀 Start with: npm run dev:backend && npm run dev:frontend"
