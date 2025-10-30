# Flutter Error Handling Guide

## ⚠️ IMPORTANT: This is Flutter, NOT React!

Flutter has its own **native** error handling patterns. Do NOT import React concepts like "Error Boundaries" into Flutter.

---

## 🎯 The Flutter Way

### 1. Global Error Handling (Uncaught Errors)

**Location:** `frontend/lib/main.dart`

Flutter provides THREE native mechanisms for catching errors:

```dart
void main() {
  // 1. Widget build errors - shows custom error UI
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kDebugMode) {
      return ErrorWidget(details.exception); // Debug: show red screen
    }
    return YourCustomErrorWidget(); // Production: graceful display
  };

  // 2. Framework errors (sync errors in Flutter code)
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
    // Send to error tracking: Sentry, Firebase Crashlytics, etc.
  };

  // 3. Async errors (futures, streams that escape Flutter)
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Async error: $error');
    return true; // Mark as handled
  };

  runApp(MyApp());
}
```

---

## 📦 Our Error Display Components

### ErrorDisplay (Organism) - Full-Page Errors

Use for **route-level errors** (404, 403, 500, etc.)

```dart
// In router
return MaterialPageRoute(
  builder: (_) => ErrorDisplay.notFound(requestedPath: path),
);

// Custom full-page error
ErrorDisplay(
  errorCode: '500',
  title: 'Server Error',
  description: 'Something went wrong on our end.',
  icon: Icons.cloud_off,
  actions: [
    ErrorAction.retry(onRetry: _reload),
    ErrorAction.navigate(label: 'Go Home', route: '/'),
  ],
);
```

**Factory Constructors:**

- `ErrorDisplay.notFound()` - 404 errors
- `ErrorDisplay.unauthorized()` - 403 errors
- `ErrorDisplay.error()` - 500 errors

---

### ErrorCard (Molecule) - Inline Component Errors

Use for **component-level failures** inside a page

```dart
// Inside a FutureBuilder or try-catch
ErrorCard(
  title: 'Failed to Load Users',
  message: error.toString(),
  actions: [
    ErrorAction.retry(onRetry: _loadUsers),
  ],
);

// Factory constructors
ErrorCard.network(onRetry: _loadData);
ErrorCard.loadFailed(
  resourceName: 'Users',
  error: error.toString(),
  onRetry: _loadUsers,
);
ErrorCard.compact(
  message: 'Save failed',
  onRetry: _save,
);
```

---

## 🔄 Async Data Loading Patterns

### Pattern 1: AsyncDataWidget (Recommended)

**The easiest way** - wraps FutureBuilder with built-in error handling:

```dart
AsyncDataWidget<List<User>>(
  future: _apiService.fetchUsers(),
  builder: (context, users) {
    return UserList(users: users);
  },
  errorTitle: 'Failed to Load Users',
  onRetry: () => _apiService.fetchUsers(),
);
```

### Pattern 2: Raw FutureBuilder

**When you need more control:**

```dart
FutureBuilder<List<User>>(
  future: _loadUsers(),
  builder: (context, snapshot) {
    // Loading
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }

    // Error - show ErrorCard!
    if (snapshot.hasError) {
      return ErrorCard(
        title: 'Failed to Load Users',
        message: snapshot.error.toString(),
        actions: [ErrorAction.retry(onRetry: _reload)],
      );
    }

    // Success
    if (snapshot.hasData) {
      return UserList(users: snapshot.data!);
    }

    return SizedBox.shrink();
  },
);
```

### Pattern 3: StreamDataWidget

**For real-time data:**

```dart
StreamDataWidget<List<Message>>(
  stream: _messageStream,
  builder: (context, messages) {
    return MessageList(messages: messages);
  },
  errorTitle: 'Connection Lost',
);
```

### Pattern 4: StatefulAsyncWidget

**For complex state management with retry:**

```dart
class UserListWidget extends StatefulAsyncWidget<List<User>> {
  @override
  Future<List<User>> loadData() => _apiService.fetchUsers();

  @override
  Widget buildData(BuildContext context, List<User> users) {
    return UserList(users: users);
  }

  @override
  String get errorTitle => 'Failed to Load Users';
}
```

---

## 🚫 What NOT to Do

### ❌ DON'T: Create "Error Boundaries" (React Pattern)

```dart
// ❌ WRONG - This is React thinking!
ErrorBoundary(
  child: MyWidget(),
);
```

**Why?** Flutter doesn't work like React. Use FutureBuilder, StreamBuilder, and proper error states instead.

### ❌ DON'T: Use try-catch in build()

```dart
// ❌ WRONG - Don't catch build errors this way
@override
Widget build(BuildContext context) {
  try {
    return MyWidget();
  } catch (e) {
    return ErrorWidget();
  }
}
```

**Why?** Use Flutter's built-in error handling (`ErrorWidget.builder`, `FutureBuilder`, etc.)

### ❌ DON'T: Inline hardcoded colors

```dart
// ❌ WRONG
Icon(Icons.error, color: Colors.red);

// ✅ CORRECT - Use theme
Icon(Icons.error, color: theme.colorScheme.error);

// ✅ CORRECT - Use AppColors
Icon(Icons.error, color: AppColors.error);
```

---

## 📚 Usage Examples

### Example 1: API Call with Error Handling

```dart
class UserProfileScreen extends StatelessWidget {
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: AsyncDataWidget<User>(
        future: _apiService.fetchUser(userId),
        builder: (context, user) => UserProfile(user: user),
        errorTitle: 'Failed to Load Profile',
        onRetry: () => _apiService.fetchUser(userId),
      ),
    );
  }
}
```

### Example 2: List with Pull-to-Refresh

```dart
class UsersListWidget extends StatefulWidget {
  @override
  State<UsersListWidget> createState() => _UsersListWidgetState();
}

class _UsersListWidgetState extends State<UsersListWidget> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = _apiService.fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadUsers();
      },
      child: AsyncDataWidget<List<User>>(
        future: _usersFuture,
        builder: (context, users) {
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) => UserListTile(user: users[i]),
          );
        },
        errorTitle: 'Failed to Load Users',
        onRetry: () {
          _loadUsers();
          return _usersFuture;
        },
      ),
    );
  }
}
```

### Example 3: Form with Error Handling

```dart
Future<void> _saveUser() async {
  try {
    await _apiService.saveUser(_user);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User saved successfully')),
      );
    }
  } catch (error) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: ErrorCard.compact(
            message: 'Failed to save: ${error.toString()}',
            onRetry: _saveUser,
          ),
        ),
      );
    }
  }
}
```

---

## 🎨 Theming

**Always use centralized theme!**

```dart
// ✅ Use Theme.of(context)
final theme = Theme.of(context);
Icon(Icons.error, color: theme.colorScheme.error);

// ✅ Use AppColors
import '../../config/app_colors.dart';
Icon(Icons.error, color: AppColors.error);

// ✅ Use AppSpacing
import '../../config/app_spacing.dart';
Padding(padding: context.spacing.paddingMD);

// ❌ NO inline values!
Icon(Icons.error, color: Colors.red); // WRONG
Padding(padding: EdgeInsets.all(16)); // WRONG
```

---

## 🧪 Testing

```dart
testWidgets('ErrorCard shows retry button', (tester) async {
  bool retried = false;

  await tester.pumpWidget(
    MaterialApp(
      home: ErrorCard(
        title: 'Test Error',
        message: 'Error message',
        actions: [
          ErrorAction.retry(
            onRetry: (context) async {
              retried = true;
            },
          ),
        ],
      ),
    ),
  );

  expect(find.text('Test Error'), findsOneWidget);
  expect(find.text('Retry'), findsOneWidget);

  await tester.tap(find.text('Retry'));
  await tester.pumpAndSettle();

  expect(retried, isTrue);
});
```

---

## 📖 Key Takeaways

1. **Use Flutter's native patterns**: ErrorWidget.builder, FutureBuilder, StreamBuilder
2. **No React patterns**: Don't create "error boundaries"
3. **AsyncDataWidget** for easy async loading with errors
4. **ErrorCard** for component-level errors
5. **ErrorDisplay** for full-page errors
6. **Always use centralized theme** - no inline colors/spacing
7. **Test your error handling** with Flutter widget tests

---

## 🔗 Related Files

- `/frontend/lib/widgets/organisms/error_display.dart` - Full-page error displays
- `/frontend/lib/widgets/molecules/error_card.dart` - Inline error cards
- `/frontend/lib/widgets/helpers/async_data_widget.dart` - Async loading helpers
- `/frontend/lib/config/app_colors.dart` - Centralized colors
- `/frontend/lib/config/app_spacing.dart` - Centralized spacing
- `/frontend/lib/config/app_theme.dart` - Material 3 theme

---

**Remember: This is Flutter, not React. Use Flutter's patterns!** 🎯
