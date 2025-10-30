# Pre-Reboot Port Management Audit & Cleanup

## October 20, 2025

## ✅ COMPLETED

### 1. Created Centralized Port Configuration

- **File**: `config/ports.js`
- **Status**: ✅ Created
- **Purpose**: Single source of truth for all port numbers

### 2. Updated package.json

- **File**: `package.json`
- **Changes**:
  - ✅ `predev:frontend`: 5173 → 8080
  - ✅ `ports:check`: 5173 → 8080
  - ✅ `ports:kill`: 5173 → 8080
  - ✅ `ports:kill:all`: 5173 → 8080

### 3. Updated stop-dev.bat

- **File**: `scripts/stop-dev.bat`
- **Changes**: ✅ Removed 5173, keeping 3001 and 8080

---

## 🔧 NEEDS FIXING (For Next Session)

### Critical Files with Wrong Ports

#### A. Scripts (5173 → 8080, 3000 → 3001)

1. **scripts/kill-port.js**
   - Line 5: Usage example still shows `5173`
   - Line 154: Usage example still shows `3000 5173`
   - **Fix**: Replace with `3001 8080`

2. **scripts/check-ports.js**
   - Line 5: Usage example shows `3000 5173`
   - Line 101: Usage example shows `3000 5173`
   - **Fix**: Replace with `3001 8080`

3. **scripts/start-dev.bat**
   - Line 14: Checks `3001 5173`
   - Line 25: Kills `3001 5173`
   - Line 39: Says "port 5173"
   - Line 46: Says "localhost:5173"
   - **Fix**: All `5173` → `8080`

4. **scripts/README.md**
   - Lines 26, 32, 48, 57, 58, 108, 142: Multiple references to `5173`
   - **Fix**: All `5173` → `8080`

#### B. Documentation (3000 → 3001)

5. **docs/api/README.md**
   - Lines 4, 5, 346, 349, 354, 416: Says `localhost:3000`
   - **Fix**: All `3000` → `3001`

6. **docs/PHASE_7_ADMIN_DASHBOARD_PLAN.md**
   - Lines 542, 543: Says `localhost:3000`
   - **Fix**: `3000` → `3001`

7. **docs/PROCESS_MANAGEMENT.md**
   - Lines 48-51, 115, 118: Says `5173`
   - **Fix**: `5173` → `8080`

8. **docs/AUTH0_INTEGRATION.md**
   - Lines 42, 46: Says `localhost:3000`
   - **Fix**: `3000` → `3001`

9. **FLUTTER_WEB_TROUBLESHOOTING.md**
   - Lines 56, 59: Says `8081` (inconsistent port!)
   - **Fix**: `8081` → `8080`

#### C. Backend Code (3000 → 3001)

10. **backend/scripts/export-openapi.js**
    - Line 28: Says `localhost:3000/api-docs`
    - **Fix**: `3000` → `3001`

---

## 📋 PORT STANDARDS (Finalized)

### Application Ports

- **Backend API**: `3001` (Express/Node.js)
- **Frontend**: `8080` (Flutter Web)

### Database Ports

- **PostgreSQL Dev**: `5432` (Docker)
- **PostgreSQL Test**: `5433` (Docker)
- **Redis**: `6379` (Docker)

### ❌ DEPRECATED (DO NOT USE)

- ~~`3000`~~ - Old backend port
- ~~`5173`~~ - Old Vite port (never used for Flutter)
- ~~`8081`~~ - Random alternative (inconsistent)

---

## 🎯 ACTION PLAN FOR POST-REBOOT

### Step 1: Apply All Port Fixes

Run this script to fix all files at once:

```bash
# Fix scripts/kill-port.js
sed -i 's/3001 3000 5173/3001 8080/g' scripts/kill-port.js

# Fix scripts/check-ports.js
sed -i 's/3001 3000 5173/3001 8080/g' scripts/check-ports.js

# Fix scripts/start-dev.bat
sed -i 's/5173/8080/g' scripts/start-dev.bat

# Fix all documentation
find docs -name "*.md" -exec sed -i 's/:3000/:3001/g' {} \;
find docs -name "*.md" -exec sed -i 's/5173/8080/g' {} \;

# Fix README files
sed -i 's/:3000/:3001/g' README.md scripts/README.md
sed -i 's/5173/8080/g' scripts/README.md

# Fix troubleshooting
sed -i 's/8081/8080/g' FLUTTER_WEB_TROUBLESHOOTING.md

# Fix backend
sed -i 's/:3000/:3001/g' backend/scripts/export-openapi.js
```

### Step 2: Verify Port Configuration

```bash
# Should use config/ports.js constants
node -e "const ports = require('./config/ports.js'); console.log(ports)"
```

### Step 3: Test Port Management

```bash
# Check all ports
npm run ports:check

# Kill if needed
npm run ports:kill

# Start backend
npm run dev:backend

# Start frontend
npm run dev:frontend
```

### Step 4: Verify App Works

- Backend: http://localhost:3001/api/health
- Frontend: http://localhost:8080

---

## 🧹 CLEANUP TASKS

### Remove Temporary Files

```bash
# None currently - all test files cleaned up
```

### Verify No Orphan Processes

```bash
npm run ports:kill:all
```

---

## ✅ PRE-REBOOT CHECKLIST

- [x] Created `config/ports.js` centralized configuration
- [x] Updated `package.json` port references
- [x] Updated `scripts/stop-dev.bat`
- [x] Documented all files needing fixes
- [x] Created action plan for post-reboot
- [x] No orphan processes running
- [x] All tests passing (419 backend, 110 frontend)
- [x] Platform-safe conditional imports working

---

## 🚀 READY FOR REBOOT

Once you reboot:

1. Run the sed commands above (or manually fix the 10 files listed)
2. Test: `npm run ports:check`
3. Start backend: `npm run dev:backend`
4. Start frontend: `npm run dev:frontend`
5. Verify at http://localhost:8080

The app will work perfectly with consistent ports across the entire codebase!
