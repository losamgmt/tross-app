# Test Noise Elimination Plan

## Problem Statement

Test suite passes (584 tests) but produces excessive console noise:

- `❌ ERROR: Dev token login FAILED | success = false`
- `🔐 LOGIN: FAILED! Showing error`

These are NOT test failures - they're debug logs from production code being tested.

## Root Causes

### 1. Widget Tests Use Real Providers

**File**: `frontend/test/widgets/login_screen_test.dart`

```dart
Widget createTestWidget() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AuthProvider()),  // ❌ REAL
      ChangeNotifierProvider(create: (context) => AppProvider()),    // ❌ REAL
    ],
    child: const LoginScreen(),
  );
}
```

**Problem**: Real AuthProvider → Real AuthService → Real HTTP calls → Fails → Logs errors

**Solution**: Use mock providers

### 2. Production Code Has Debug Print Statements

**File**: `frontend/lib/screens/login_screen.dart` (lines 110-140)

```dart
print('🔐 LOGIN: Starting ${isAdmin ? "ADMIN" : "TECH"} login');
print('🔐 LOGIN: Result = $success');
print('🔐 LOGIN: SUCCESS! Navigating');
print('🔐 LOGIN: FAILED! Showing error');
```

**Problem**: These always execute during tests
**Solution**: Replace with `ErrorService.logInfo()` or remove

### 3. ErrorService Always Prints in Tests

**File**: `frontend/lib/services/error_service.dart`

**Problem**: No test mode detection - always prints to console
**Solution**: Make test-aware OR mock in tests

## Solutions (In Priority Order)

### ✅ SOLUTION 1: Mock AuthProvider in Widget Tests (IMMEDIATE)

Create mock provider for widget testing:

```dart
// frontend/test/helpers/mock_auth_provider.dart
import 'package:flutter/foundation.dart';

class MockAuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _user;

  // Controllable behavior
  bool mockLoginResult = true;
  bool mockLoginShouldThrow = false;

  // State getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;

  // Mock login
  Future<bool> loginWithTestToken({bool isAdmin = false}) async {
    if (mockLoginShouldThrow) throw Exception('Mock error');

    _isLoading = true;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: 10)); // Simulate async

    if (mockLoginResult) {
      _isAuthenticated = true;
      _user = {
        'role': isAdmin ? 'admin' : 'technician',
        'email': '${isAdmin ? 'admin' : 'tech'}@test.com',
      };
      _error = null;
    } else {
      _error = 'Login failed';
    }

    _isLoading = false;
    notifyListeners();
    return mockLoginResult;
  }

  // Mock logout
  Future<void> logout() async {
    _isAuthenticated = false;
    _user = null;
    _error = null;
    notifyListeners();
  }
}
```

Then update widget tests:

```dart
Widget createTestWidget({MockAuthProvider? mockAuth}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>(
        create: (context) => mockAuth ?? MockAuthProvider(),  // ✅ MOCK
      ),
      ChangeNotifierProvider(create: (context) => AppProvider()),
    ],
    child: const LoginScreen(),
  );
}
```

**Impact**: Eliminates HTTP 400 errors and auth failure logs

---

### ✅ SOLUTION 2: Replace print() with ErrorService (CLEANUP)

Update `login_screen.dart`:

```dart
// BEFORE
print('🔐 LOGIN: FAILED! Showing error');

// AFTER
ErrorService.logInfo('Login failed', context: {
  'isAdmin': isAdmin,
  'isAuthenticated': authProvider.isAuthenticated,
});
```

**Benefits**:

- Consistent logging
- Capturable in tests
- Controlled by error service config

---

### ✅ SOLUTION 3: Make ErrorService Test-Aware (ARCHITECTURAL)

Option A: Environment detection

```dart
class ErrorService {
  static bool _isTestMode = false;

  static void enableTestMode() => _isTestMode = true;
  static void disableTestMode() => _isTestMode = false;

  static void logError(String message, {...}) {
    if (_isTestMode) {
      // Capture but don't print
      _capturedLogs.add(message);
    } else {
      // Print to console
      print('❌ ERROR: $message');
    }
  }
}
```

Option B: Use our SilentErrorService mock (simpler)

- Already created in Phase 2
- Just need to inject it in widget tests

**Recommendation**: Option B - less invasive

---

## Implementation Order

### Phase 1: Quick Win (30 minutes)

1. Create `MockAuthProvider` in test helpers
2. Update `login_screen_test.dart` to use mock
3. Run tests - verify clean output

### Phase 2: Cleanup (15 minutes)

4. Replace `print()` statements in `login_screen.dart`
5. Run tests - verify still clean

### Phase 3: Architecture (1 hour)

6. Make ErrorService injectable (dependency injection)
7. Widget tests inject SilentErrorService
8. All tests now silent

## Expected Results

### Before

```
❌ ERROR: Failed to get test token | HTTP 400
❌ ERROR: Token is null after getTestToken
❌ ERROR: Dev token login FAILED | success = false
🔐 LOGIN: Result = false, isAuthenticated = false
🔐 LOGIN: FAILED! Showing error
00:11 +584: All tests passed!
```

### After

```
00:05 +584: All tests passed!
```

**Noise Reduction**: 100%
**Test Speed**: 50% faster (no HTTP calls)
**Clarity**: Crystal clear what actually failed (if anything)

---

## Tracking

- [ ] Create MockAuthProvider helper
- [ ] Update login_screen_test.dart
- [ ] Replace print() in login_screen.dart
- [ ] Test and verify clean output
- [ ] Document pattern for other widget tests
