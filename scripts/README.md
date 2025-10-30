# Process & Port Management Scripts

Professional utilities for managing Node.js processes and port conflicts in the TrossApp development environment.

## Overview

These scripts provide robust, cross-platform process and port management:

- **Port checking** - Detect processes using specific ports
- **Port cleanup** - Kill processes on specific ports
- **Service health checks** - Wait for services to be ready
- **Automatic pre-dev cleanup** - Ensure clean starts every time

## Scripts

### `check-ports.js`

Check if ports are available before starting services.

```bash
node scripts/check-ports.js <port1> [port2] [port3] ...
```

**Example:**

```bash
node scripts/check-ports.js 3001 8080 5432
```

**Output:**

```
✅ Port 3001 is available
✅ Port 8080 is available
❌ Port 5432 is IN USE
   Process: postgres.exe (PID: 7024)
   To free: node scripts/kill-port.js 5432
```

### `kill-port.js`

Kill processes using specific ports (works on Windows, Mac, Linux).

```bash
node scripts/kill-port.js <port1> [port2] [port3] ...
```

**Example:**

```bash
node scripts/kill-port.js 3001 8080
```

**Output:**

```
🔍 Checking port 3001...
⚠️  Found process on port 3001: node.exe (PID: 4852)
✅ Successfully killed process 4852 on port 3001

🔍 Checking port 8080...
✅ Port 8080 is free
```

### `wait-for-service.js`

Wait for a service to be ready by polling its health endpoint.

```bash
node scripts/wait-for-service.js <url> [max-attempts] [delay-ms]
```

**Example:**

```bash
node scripts/wait-for-service.js http://localhost:3001/api/health 30 1000
```

**Output:**

```
⏳ Waiting for service at http://localhost:3001/api/health...
   Max attempts: 30, Delay: 1000ms

   Attempt 1/30... ✅ SUCCESS

✅ Service is ready at http://localhost:3001/api/health
```

## NPM Scripts

These utilities are integrated into npm scripts for automatic use:

### Port Management

```bash
# Check all TrossApp ports
npm run ports:check

# Kill development server ports
npm run ports:kill

# Kill all ports including databases
npm run ports:kill:all
```

# Development Scripts

This directory contains helper scripts for development workflow.

## Quick Start (Windows)

```bash
# Start everything
npm run start:dev     # or: scripts\start-dev.bat

# Frontend hanging? Run this first
npm run fix:frontend  # or: scripts\fix-frontend.bat

# Individual services
npm run dev:backend       # Backend only (port 3001)
npm run dev:frontend:win  # Frontend only (port 8080) - Windows optimized

# Stop everything
npm run stop             # or: scripts\stop-dev.bat
```

## Troubleshooting

### Frontend Hangs at "Waiting for connection..."

This is a common Flutter Web + Chrome issue on Windows. **Solutions:**

1. **Quick Fix (Recommended):**

   ```bash
   npm run fix:frontend
   ```

   This script will:
   - Kill all Chrome processes
   - Free port 8080
   - Clean Flutter cache
   - Reset dependencies

2. **Manual Steps:**

   ```bash
   # Kill Chrome
   taskkill /F /IM chrome.exe

   # Clean Flutter
   cd frontend
   rmdir /s /q build .dart_tool
   flutter pub get
   ```

3. **Use Windows-Optimized Script:**
   ```bash
   npm run dev:frontend:win
   ```
   Uses `--web-renderer=html` for better Windows compatibility

### Port Already in Use

```bash
# Check which ports are in use
npm run ports:check

# Kill processes on specific ports
npm run ports:kill  # Kills 3001 and 8080
```

## Available Scripts

### Development

- `start-dev.bat` - **Main entry point** - Starts both backend and frontend
- `stop-dev.bat` - Stops all development servers
- `dev.sh` / `dev.bat` - Quick single-service start
- `flutter-dev-win.bat` - **NEW** - Windows-optimized Flutter start

### Port Management

- `check-ports.js` - Verifies if required ports are available
- `kill-port.js` - Kills processes using specified ports
- `fix-ports.sh` / `fix-ports.bat` - Automated port cleanup

### Flutter

- `flutter-clean.sh` / `flutter-clean.bat` - Cleans Flutter cache
- `flutter-test-safe.sh` / `flutter-test-safe.bat` - Safe Flutter test runner
- `flutter-dev-win.bat` - **NEW** - Windows-specific Flutter dev start
- `fix-frontend.bat` - **NEW** - Complete frontend troubleshooting

### Database

- `db-manage.sh` - Database management utilities
- `wait-for-service.js` - Waits for a service to be ready

## Common Issues

### 1. "Port 8080 is already in use"

```bash
npm run ports:kill
# or manually:
node scripts/kill-port.js 8080
```

### 2. "Flutter build cache corrupted"

```bash
cd frontend
rmdir /s /q build .dart_tool windows\flutter\ephemeral
flutter pub get
```

### 3. "Chrome won't close properly"

```bash
taskkill /F /IM chrome.exe
```

### 4. "Backend won't start"

```bash
# Check if port is in use
netstat -ano | findstr :3001

# Kill it
node scripts/kill-port.js 3001
```

## Port Configuration

- **Backend:** 3001
- **Frontend:** 8080
- **PostgreSQL Dev:** 5432
- **PostgreSQL Test:** 5433
- **PostgreSQL Docker:** 5434

## Tips

1. **Always use `npm run dev:frontend:win` on Windows** - it's optimized for Windows + Chrome
2. **If frontend hangs, run `npm run fix:frontend` first** - it fixes 90% of issues
3. **Use `start-dev.bat` for full environment** - it handles port checks automatically
4. **Check backend health:** http://localhost:3001/api/health

## Windows Batch Scripts

### `start-dev.bat`

Start both backend and frontend with automatic port cleanup.

```batch
scripts\start-dev.bat
```

Features:

- Checks port availability
- Prompts to kill existing processes
- Starts both servers in separate terminal windows
- Shows service URLs

### `stop-dev.bat`

Stop all TrossApp processes and clean up ports.

```batch
scripts\stop-dev.bat
```

Features:

- Kills processes on ports 3001, 8080, 8080
- Cleans up Flutter/Dart processes
- Cleans up Node processes

## CI/CD Integration

These scripts are perfect for CI/CD pipelines:

```yaml
# GitHub Actions example
- name: Check ports
  run: node scripts/check-ports.js 3001 5432

- name: Wait for backend
  run: node scripts/wait-for-service.js http://localhost:3001/api/health 60 1000

- name: Cleanup
  if: always()
  run: node scripts/kill-port.js 3001 5432
```

## Error Handling

All scripts:

- Exit with code `0` on success
- Exit with code `1` on failure
- Provide detailed error messages
- Work cross-platform (Windows/Mac/Linux)

## Technical Details

### Port Detection

**Windows:** Uses `netstat -ano` and `tasklist`
**Unix/Linux/Mac:** Uses `lsof` and `ps`

### Process Killing

**Windows:** Uses `taskkill /F`
**Unix/Linux/Mac:** Uses `kill -9`

### Platform Detection

Automatically detects OS using `os.platform()` and adjusts commands accordingly.

## Best Practices

1. **Always check ports before starting services**

   ```bash
   npm run ports:check
   ```

2. **Use pre-dev hooks for automatic cleanup**

   ```json
   "predev:backend": "node scripts/check-ports.js 3001 || node scripts/kill-port.js 3001"
   ```

3. **Wait for services in integration tests**

   ```bash
   npm run dev:backend &
   node scripts/wait-for-service.js http://localhost:3001/api/health
   npm run test:integration
   ```

4. **Clean up in CI/CD cleanup steps**
   ```yaml
   - name: Cleanup
     if: always()
     run: npm run ports:kill:all
   ```

## Troubleshooting

### "Port already in use" errors

```bash
# Find what's using the port
node scripts/check-ports.js 3001

# Kill the process
node scripts/kill-port.js 3001
```

### Services won't start

```bash
# Check all ports
npm run ports:check

# Kill all development ports
npm run ports:kill

# Try starting again
npm run dev:backend
```

### Orphaned processes

```bash
# Kill all TrossApp-related ports
npm run ports:kill:all

# On Windows, also run
scripts\stop-dev.bat
```

## Contributing

When adding new services:

1. Add port to `ports:check` script in `package.json`
2. Add port to `ports:kill:all` script
3. Add `predev:<service>` script for automatic cleanup
4. Update this documentation

## Related Documentation

- [Development Workflow](../docs/DEVELOPMENT_WORKFLOW.md)
- [Testing Strategy](../docs/testing/TESTING_STRATEGY.md)
- [Docker Compose](../docker-compose.yml)
