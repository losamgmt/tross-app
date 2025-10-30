# 🔄 POST-REBOOT CHECKLIST

## Date: October 22, 2025

## Issue: Frontend won't load - Flutter builds but doesn't serve on port 8080

---

## ✅ STEP 1: Verify Docker & Databases

### Start Docker Services

```bash
cd c:/Users/zarik/OneDrive/Desktop/TrossApp
docker-compose up -d
```

### Verify All 3 Databases

```bash
# Check containers are running
docker ps

# Should see:
# - trossapp-db-1 (PostgreSQL main - port 5432)
# - trossapp-test-db-1 (PostgreSQL test - port 5433)
# - trossapp-redis-1 (Redis - port 6379)
```

### Test Database Connections

```bash
# Main DB (dev)
docker exec -it trossapp-postgres psql -U postgres -d trossapp_dev -c "SELECT 1;"

# Test DB
docker exec -it trossapp-postgres-test psql -U postgres -d trossapp_test -c "SELECT 1;"

# Redis
docker exec -it trossapp-redis redis-cli ping
```

**Expected:** All should respond successfully.

---

## ✅ STEP 2: Verify Backend

### Start Backend

```bash
cd c:/Users/zarik/OneDrive/Desktop/TrossApp
npm run dev:backend
```

### Test Backend Health

```bash
# In a new terminal
curl http://localhost:3001/api/health

# Should return:
# {
#   "status": "healthy",
#   "timestamp": "...",
#   "services": {...},
#   "memory": {...}
# }
```

### Run Backend Tests

```bash
cd backend
npm test

# Expected: All 473 tests passing
```

**If tests fail:** Check database connections and migrations.

---

## ✅ STEP 3: Debug Frontend (The Problem Child)

### Option A: Try Build & Serve Separately

```bash
cd frontend

# 1. Build the web app
flutter build web --profile

# 2. Check if build succeeded
ls build/web/index.html

# 3. Serve with a simple HTTP server
# Option 3a: Python
python -m http.server 8080 --directory build/web

# Option 3b: Node http-server (install if needed)
npx http-server build/web -p 8080

# Option 3c: Flutter serve (if available)
flutter serve --web-port=8080
```

### Option B: Use Windows CMD Instead of Git Bash

```cmd
cd frontend
flutter run -d chrome --web-port=8080 --profile
```

### Option C: Try Edge Instead of Chrome

```bash
cd frontend
flutter run -d edge --web-port=8080 --profile
```

### Option D: Check Flutter's Built-in Web Server

```bash
cd frontend

# Start Flutter DevTools first
dart devtools

# Then in another terminal, run with explicit observatory port
flutter run -d chrome --web-port=8080 --profile --observatory-port=9200
```

---

## 🔍 DIAGNOSTIC COMMANDS

### Check Ports

```bash
# Windows
netstat -ano | findstr "3001 8080 5432 5433 6379"

# Should show:
# 3001 - Backend (LISTENING)
# 8080 - Frontend (LISTENING) ← THIS IS THE PROBLEM
# 5432 - PostgreSQL main
# 5433 - PostgreSQL test
# 6379 - Redis
```

### Check Flutter Doctor

```bash
cd frontend
flutter doctor -v

# Look for:
# - Chrome version
# - Web support enabled
# - Any warnings about web debugging
```

### Check Chrome Processes

```bash
tasklist | findstr chrome
```

### Check Firewall Rules

```powershell
# Run as Administrator
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*Flutter*" -or $_.DisplayName -like "*Chrome*"}
```

---

## 🎯 EXPECTED WORKING STATE

After successful startup:

1. **Docker:** 3 containers running
2. **Backend:** Port 3001 listening, health check returns 200
3. **Frontend:** Port 8080 listening, browser shows login page
4. **Tests:** 353 frontend + 473 backend = 826 total passing

---

## 🚨 KNOWN ISSUES

### Issue #1: Flutter Web Debug Service Hang

- **Symptom:** "Waiting for connection from debug service on Chrome..."
- **Cause:** Windows Firewall/Antivirus blocking debug connection
- **Solution:** Use `--profile` or `--release` mode (NOT debug mode)
- **See:** `docs/FLUTTER_WEB_DEBUG_ISSUE.md`

### Issue #2: Flutter Builds But Doesn't Serve

- **Symptom:** "Built build\web" but port 8080 not listening
- **Cause:** Unknown - Flutter's internal web server isn't starting
- **Solution:** Try manual build + serve (see Option A above)

### Issue #3: Port Already in Use

- **Solution:**
  ```bash
  npm run ports:kill  # Kills 3001 and 8080
  # OR
  node scripts/kill-port.js 8080
  ```

---

## 📝 NEXT STEPS AFTER FRONTEND WORKS

Once frontend is reliably loading:

1. **Update Todo List:** Mark Phase 3.1 as complete (backend health endpoints done - 30 tests)
2. **Phase 3.2:** Create ConnectionStatusBadge atom
3. **Phase 3.3:** Create DatabaseHealthCard molecule
4. **Phase 3.4:** Create DbHealthDashboard organism
5. **Phase 3.5:** Integrate health dashboard into admin page
6. **Phase 3.6:** Write comprehensive tests

---

## 🔗 USEFUL DOCS

- `docs/FLUTTER_WEB_DEBUG_ISSUE.md` - Why debug mode hangs
- `scripts/README.md` - All available scripts
- `docs/DATABASE_ARCHITECTURE.md` - Database setup
- `docs/DEVELOPMENT_WORKFLOW.md` - Development process

---

## 💡 ALTERNATIVE: SKIP FLUTTER WEB TEMPORARILY

If Flutter Web continues to be problematic, consider:

1. **Focus on backend Phase 3 work first** (health endpoints are done)
2. **Use Flutter Desktop** for development:
   ```bash
   flutter run -d windows
   ```
3. **Use Mobile Emulator:**
   ```bash
   flutter run -d android  # or -d ios
   ```
4. **Research Flutter Web alternatives:**
   - Try older Flutter version (3.27.x)?
   - Check Flutter Web Discord/Reddit for Windows workarounds
   - Consider using WSL2 for Flutter Web development

---

## 🎯 SUCCESS CRITERIA

✅ Docker containers running  
✅ Backend health endpoint responding  
✅ Backend tests passing (473)  
✅ Frontend tests passing (353)  
✅ **Frontend visible in browser at http://localhost:8080** ← THIS IS THE GOAL  
✅ Login page shows Auth0 + Dev cards  
✅ DevModeBanner visible (development mode)

---

**Good luck! The issue is specifically that Flutter says it built but never actually starts the web server on port 8080.**
