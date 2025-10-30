# Flutter Web Development Troubleshooting Guide

## Current Issue: Port 8080 Connection Refused

### What We Tried (October 19, 2025):

1. ✅ Backend running successfully on port 3001
2. ✅ Database connected
3. ❌ Flutter web stuck at "Waiting for connection from debug service"
4. ❌ Port 8080 shows LISTENING but browser can't connect
5. ❌ Even after killing PID, connection refused

### Root Cause:

Flutter web debug mode on Windows can have issues with Chrome's DevTools protocol connection.

---

## **Post-Reboot: Try These Commands in Order**

### **Option 1: Use Release Mode (Recommended)**

```bash
# Terminal 1: Backend
npm run dev:backend

# Terminal 2: Frontend (Release mode - no debugging)
cd frontend
flutter run -d chrome --web-port=8080 --release
```

**Why:** Release mode bypasses all debug protocol issues.

---

### **Option 2: Use Web Server Mode**

```bash
# Terminal 1: Backend
npm run dev:backend

# Terminal 2: Frontend (Web server mode)
cd frontend
flutter run -d web-server --web-port=8080
```

Then manually open `http://localhost:8080/` in your browser.

**Why:** This runs a simple HTTP server without browser control.

---

### **Option 3: Use Different Port**

```bash
# Terminal 1: Backend
npm run dev:backend

# Terminal 2: Frontend (Different port)
cd frontend
flutter run -d chrome --web-port=8080 --release
```

Then open `http://localhost:8080/`

---

### **Option 4: Use the Built-in VS Code Task**

1. Press `Ctrl+Shift+P`
2. Type: "Tasks: Run Task"
3. Select: "🚀 Start TrossApp Development"

This uses the pre-configured startup script.

---

## **Diagnostic Commands**

### Check if ports are in use:

```bash
netstat -ano | findstr :3001
netstat -ano | findstr :8080
```

### Kill specific process:

```bash
taskkill //F //PID <PID_NUMBER>
```

### Check backend health:

```bash
curl http://localhost:3001/api/health
```

### Clear all Flutter cache:

```bash
cd frontend
flutter clean
flutter pub get
```

---

## **Common Issues & Solutions**

### Issue: "Waiting for connection from debug service"

**Solution:** Use `--release` or `--profile` mode instead of debug mode

### Issue: Port already in use

**Solution:**

```bash
netstat -ano | findstr :8080
taskkill //F //PID <PID>
```

### Issue: Chrome opens but shows blank page

**Solution:**

1. Check Chrome console (F12) for errors
2. Verify backend is running
3. Check CORS settings in backend

### Issue: "Site can't be reached" even though port is listening

**Solution:**

1. Reboot (Windows networking issue)
2. Try different port
3. Disable Windows Firewall temporarily
4. Try Edge browser instead: `flutter run -d edge --web-port=8080`

---

## **Windows Firewall Check**

If still having issues after reboot:

1. Open Windows Defender Firewall
2. Click "Allow an app through firewall"
3. Ensure these are allowed:
   - Chrome
   - Dart
   - Flutter
   - Node.js

---

## **Nuclear Option: Complete Reset**

```bash
# Kill all related processes
taskkill //F //IM chrome.exe
taskkill //F //IM dart.exe
taskkill //F //IM flutter.exe
taskkill //F //IM node.exe

# Clean Flutter
cd frontend
flutter clean
flutter pub get

# Restart backend
cd ..
npm run dev:backend

# Start frontend in release mode
cd frontend
flutter run -d chrome --web-port=8080 --release
```

---

## **Recommended Development Workflow**

### Daily Startup:

```bash
# Terminal 1: Backend
npm run dev:backend

# Terminal 2: Frontend (Release mode for stability)
cd frontend
flutter run -d chrome --web-port=8080 --release
```

### For debugging frontend issues:

```bash
# Use profile mode (has some debugging, less overhead)
cd frontend
flutter run -d chrome --web-port=8080 --profile
```

### For full debugging (when needed):

```bash
# Only use debug mode when actively debugging
cd frontend
flutter run -d chrome --web-port=8080
# Be patient - can take 30-60 seconds to connect
```

---

## **Alternative: Docker Development**

If local development continues to have issues:

```bash
npm run docker:up
```

This runs everything in containers and avoids local port/process issues.

---

## **Contact Info**

If issues persist after reboot:

- Check Flutter GitHub issues: https://github.com/flutter/flutter/issues
- Search for: "Flutter web waiting for connection Windows"
- Consider using WSL2 for more stable Flutter development on Windows

---

_Last updated: October 19, 2025_
_Issue: Port listening but connection refused - requires reboot_
