import 'package:flutter/foundation.dart';
import '../services/auth/auth_service.dart';
import '../services/error_service.dart';
import '../services/auth/auth0_platform_service.dart';

/// Authentication State Provider
/// KISS Principle: Simple, focused state management for auth operations
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // State properties
  bool _isLoading = false;
  bool _isRedirecting = false; // Track Auth0 redirect in progress
  String? _error;
  Map<String, dynamic>? _user;
  bool _isAuthenticated = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isRedirecting => _isRedirecting; // Expose redirect state
  String? get error => _error;
  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _authService.token;

  // User convenience getters
  String get userName => _user != null
      ? '${_user!['first_name'] ?? ''} ${_user!['last_name'] ?? ''}'.trim()
      : 'User';
  String get userRole => _user?['role'] ?? 'unknown';
  String get userEmail => _user?['email'] ?? '';

  /// Initialize auth state
  /// KISS Principle: No HTTP calls during initialization - just restore local state
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      // Initialize the AuthService (restores stored auth state from local storage only)
      await _authService.initialize();

      // Check if already authenticated based on stored data
      if (_authService.isAuthenticated) {
        _user = _authService.user;
        _isAuthenticated = true;
        ErrorService.logInfo('Auth state initialized - user logged in');
      } else {
        ErrorService.logInfo('Auth state initialized - no active session');
      }
    } catch (e) {
      _setError('Failed to initialize authentication');
      ErrorService.logError('Auth initialization failed', error: e);
    } finally {
      _setLoading(false);
    }
  }

  /// Login with Auth0 (production) - Works on web, iOS, Android
  Future<bool> loginWithAuth0() async {
    _setLoading(true);
    _clearError();

    // On web, mark as redirecting to prevent dashboard flash
    if (Auth0PlatformService.isWeb) {
      _isRedirecting = true;
      notifyListeners();
    }

    try {
      final success = await _authService.loginWithAuth0();

      if (success) {
        _user = _authService.user;
        _isAuthenticated = true;
        ErrorService.logInfo(
          'Auth0 login successful',
          context: {'role': _user?['role'], 'email': _user?['email']},
        );
        notifyListeners();
        return true;
      } else {
        _setError('Auth0 login failed. Please try again.');
        return false;
      }
    } catch (e) {
      _setError('Login error: ${ErrorService.getUserFriendlyMessage(e)}');
      ErrorService.logError('Auth0 login failed', error: e);
      return false;
    } finally {
      _setLoading(false);
      // Don't clear redirecting flag - browser is navigating away
    }
  }

  /// Handle Auth0 callback after redirect (web-only)
  /// Called by Auth0CallbackHandler when user returns from Auth0 login
  Future<bool> handleAuth0Callback() async {
    _setLoading(true);
    _clearError();
    _isRedirecting = false; // Clear redirect flag when callback starts

    try {
      final success = await _authService.handleAuth0Callback();

      if (success) {
        _user = _authService.user;
        _isAuthenticated = true;
        ErrorService.logInfo(
          'Auth0 callback handled successfully',
          context: {'role': _user?['role'], 'email': _user?['email']},
        );
        notifyListeners();
        return true;
      } else {
        _setError('Auth0 login failed during callback.');
        return false;
      }
    } catch (e) {
      _setError('Callback error: ${ErrorService.getUserFriendlyMessage(e)}');
      ErrorService.logError('Auth0 callback failed', error: e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Login with test token (development)
  Future<bool> loginWithTestToken({bool isAdmin = false}) async {
    _setLoading(true);
    _clearError();

    try {
      ErrorService.logInfo(
        'Starting dev token login',
        context: {'isAdmin': isAdmin},
      );

      final success = await _authService.loginWithTestToken(isAdmin: isAdmin);

      ErrorService.logInfo(
        'Dev token login result',
        context: {'success': success},
      );

      if (success) {
        _user = _authService.user;
        _isAuthenticated = true;

        ErrorService.logInfo(
          'Dev token login SUCCESS - updating state',
          context: {
            'role': _user?['role'],
            'isAdmin': isAdmin,
            'isAuthenticated': _isAuthenticated,
            'hasUser': _user != null,
          },
        );

        notifyListeners();
        return true;
      } else {
        ErrorService.logError(
          'Dev token login FAILED',
          error: 'success = false',
        );
        _setError('Login failed. Please try again.');
        return false;
      }
    } catch (e) {
      ErrorService.logError('Login error exception', error: e);
      _setError('Login error: ${ErrorService.getUserFriendlyMessage(e)}');
      ErrorService.logError('Test login failed', error: e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _authService.updateProfile(updates);

      if (success) {
        _user = _authService.user;
        ErrorService.logInfo('Profile updated successfully');
        notifyListeners();
        return true;
      } else {
        _setError('Failed to update profile');
        return false;
      }
    } catch (e) {
      _setError('Update error: ${ErrorService.getUserFriendlyMessage(e)}');
      ErrorService.logError('Profile update failed', error: e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout user
  /// KISS: Clears local state immediately, then calls auth service cleanup
  /// For Auth0 web: Triggers browser redirect to Auth0 logout (never returns)
  /// For Dev Auth: Just clears local storage (no redirect)
  Future<void> logout() async {
    _clearError();

    try {
      // Clear all auth state flags to trigger AuthStateListener redirect
      _user = null;
      _isAuthenticated = false;
      _isLoading = false; // Ensure loading is false
      _isRedirecting = false; // Ensure redirecting is false
      notifyListeners(); // Trigger AuthStateListener

      await _authService.logout();
    } catch (e) {
      ErrorService.logError('Logout error', error: e);
    }
  }

  /// Check if user has specific role
  bool hasRole(String roleName) {
    return _authService.hasRole(roleName);
  }

  /// Clear any error messages
  void clearError() {
    _clearError();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
