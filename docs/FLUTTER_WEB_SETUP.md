# Flutter Web Development Setup

## Critical Configuration - DO NOT MODIFY

### The IPv4/IPv6 Issue (RESOLVED)

**Problem:** Flutter web dev server on Windows binds ONLY to IPv6 `[::1]`, causing browsers to fail connecting via IPv4.

**Solution:** Use these flags on ALL `flutter run` commands:

```bash
--web-hostname=0.0.0.0          # Bind to ALL interfaces (IPv4 + IPv6)
--web-launch-url=http://localhost:8080  # Launch browser to correct URL
```

### Working Commands

✅ **Primary Development (Chrome with debugger):**

```bash
npm run dev:frontend
```

✅ **Web Server Mode (manual browser):**

```bash
npm run dev:frontend:server
```

✅ **Edge Browser:**

```bash
npm run dev:frontend:edge
```

### Process Cleanup

The `flutter-clean.sh` script is **INTENTIONAL** and runs before each start:

- Kills orphaned `dart.exe` processes (prevents accumulation)
- Cleans `.dart_tool` cache
- Does NOT delete `build/` (Flutter needs it)

**DO NOT REMOVE** the clean step from npm scripts!

### Why This Configuration Works

1. **`--web-hostname=0.0.0.0`** - Listens on both IPv4 and IPv6
2. **`--web-launch-url=http://localhost:8080`** - Browsers navigate to correct URL
3. **Port 8080** - Standard development port
4. **flutter-clean.sh** - Prevents orphaned process accumulation
5. **Port checking** - Prevents conflicts

### If Something Breaks

**Symptom:** Browser can't connect
**Fix:** Verify `--web-hostname=0.0.0.0` is in the command

**Symptom:** Orphaned Dart processes
**Fix:** Verify `flutter-clean.sh` runs before start

**Symptom:** Port conflicts
**Fix:** Check `predev:frontend` runs port checker

---

## Testing

✅ All 584 tests passing
✅ Zero console noise
✅ Universal logging architecture in place
✅ ErrorService working perfectly

## Architecture Status

✅ Backend: Node.js + Express on port 3001
✅ Frontend: Flutter Web on port 8080
✅ Docker: PostgreSQL (5432, 5433), Redis (6379)
✅ Monorepo: Root + backend workspace
✅ Testing: Jest (backend), Flutter test (frontend), Playwright (E2E)
