# Platform-Safe Testing Architecture - October 20, 2025

## Problem Resolved

Flutter tests were failing with `dart:html is not available on this platform` errors because web-specific code was being imported during VM-based test execution.

## Root Cause

- `dart:html` is only available in web (browser) environment
- `flutter test` runs in VM environment by default
- Direct imports of web-specific code caused compilation failures

## Solution: Conditional Imports

Implemented Flutter's conditional import pattern to provide platform-specific implementations with fallback stubs.

### Pattern Used

```dart
import 'platform_stub.dart'
    if (dart.library.html) 'platform_web.dart';
```

This syntax tells Dart:

- Use `platform_stub.dart` by default (VM, iOS, Android, etc.)
- Use `platform_web.dart` when `dart:html` is available (web platform)

## Files Created

### 1. `frontend/lib/services/auth/auth0_web_service_stub.dart`

**Purpose:** Stub implementation of Auth0WebService for non-web platforms

```dart
// Provides same interface as auth0_web_service.dart but throws UnsupportedError
class Auth0WebService {
  Future<void> login() async {
    throw UnsupportedError('Auth0WebService.login is only available on web platform');
  }

  static String? getAuthorizationCode() {
    throw UnsupportedError('Auth0WebService.getAuthorizationCode is only available on web platform');
  }

  Future<Map<String, dynamic>?> exchangeCodeForToken(String code) async {
    throw UnsupportedError('Auth0WebService.exchangeCodeForToken is only available on web platform');
  }

  Future<void> logout() async {
    throw UnsupportedError('Auth0WebService.logout is only available on web platform');
  }
}
```

### 2. `frontend/lib/utils/browser_utils_stub.dart`

**Purpose:** No-op browser utilities for non-web platforms

```dart
class BrowserUtils {
  /// Replace browser history state (web only)
  static void replaceHistoryState(String url) {
    // No-op on non-web platforms
  }
}
```

### 3. `frontend/lib/utils/browser_utils_web.dart`

**Purpose:** Real browser utilities using dart:html

```dart
import 'dart:html' as html;

class BrowserUtils {
  /// Replace browser history state (removes query parameters from URL)
  static void replaceHistoryState(String url) {
    html.window.history.replaceState(null, '', url);
  }
}
```

## Files Modified

### 1. `frontend/lib/services/auth/auth0_platform_service.dart`

**Change:** Added conditional import for web service

```dart
// Before:
import 'auth0_web_service.dart'; // Web implementation

// After:
import 'auth0_web_service_stub.dart'
    if (dart.library.html) 'auth0_web_service.dart';
```

### 2. `frontend/lib/main.dart`

**Changes:**

1. Replaced direct `dart:html` import with conditional browser utils
2. Updated `html.window.history.replaceState()` calls to use `BrowserUtils.replaceHistoryState()`

```dart
// Before:
import 'dart:html' as html;
// ...
html.window.history.replaceState(null, '', '/');

// After:
import 'utils/browser_utils_stub.dart'
    if (dart.library.html) 'utils/browser_utils_web.dart';
// ...
BrowserUtils.replaceHistoryState('/');
```

## Test Results

### Before Fix

- 70 tests passing
- 5 tests failing with `dart:html not available` errors
- Tests affected: app_test.dart, frontend_connection_test.dart, provider_initialization_test.dart, auth_provider_test.dart, login_screen_test.dart

### After Fix

- ✅ **110/110 tests passing**
- ✅ All compilation errors resolved
- ✅ Tests run successfully in VM environment
- ✅ Web platform functionality unchanged

## Key Principles Applied

### 1. Platform Abstraction

- Tests don't need real browser APIs to verify logic
- Stub implementations provide type safety without web dependencies

### 2. Interface Consistency

- Stubs match the exact interface of real implementations
- Code importing these services works seamlessly on all platforms

### 3. Clear Error Messages

- Stubs throw `UnsupportedError` with descriptive messages
- If web-specific code accidentally runs on non-web platform, error is clear

## Benefits

1. **Tests Pass on All Platforms**: VM, web, mobile
2. **No Test Environment Setup**: No need for Chrome or web server during testing
3. **Type Safety**: Stubs provide full type checking without runtime dependencies
4. **Production Unaffected**: Web builds use real implementations via conditional imports
5. **Maintainable**: Single source of truth for interfaces

## Related Documentation

- Flutter Conditional Imports: https://dart.dev/guides/libraries/create-library-packages#conditionally-importing-and-exporting-library-files
- Platform Detection: `kIsWeb` from `package:flutter/foundation.dart`

## Verification Commands

```bash
# Run frontend tests (VM environment)
cd frontend
flutter test

# Run app on web (real browser with dart:html)
flutter run -d chrome --web-port=8080 --release

# Both commands now work correctly!
```

## Status

✅ **COMPLETE** - All tests passing, no tech debt, ready for Phase 7.1 feature development.
