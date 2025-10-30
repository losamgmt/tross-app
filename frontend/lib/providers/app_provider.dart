import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/service_health_manager.dart';
import '../services/error_service.dart';

/// Application State Provider
/// KISS Principle: Manages app-wide state like connectivity, health status
class AppProvider extends ChangeNotifier {
  final ServiceHealthManager _healthManager = ServiceHealthManager();
  final Connectivity _connectivity = Connectivity();

  // State properties
  bool _isInitialized = false;
  ServiceStatus _backendStatus = ServiceStatus.unknown;
  Map<String, dynamic> _healthData = {};
  bool _isConnected = false;
  bool _hasNetworkConnection = true; // Device network connectivity
  String? _connectionError;

  // Getters
  bool get isInitialized => _isInitialized;
  ServiceStatus get backendStatus => _backendStatus;
  Map<String, dynamic> get healthData => _healthData;
  bool get isConnected => _isConnected;
  bool get hasNetworkConnection => _hasNetworkConnection;
  String? get connectionError => _connectionError;
  bool get isBackendHealthy => _backendStatus == ServiceStatus.healthy;
  bool get isBackendAvailable => _healthManager.isBackendAvailable;

  /// Initialize app state
  /// KISS Principle: Quick health check at startup for better UX
  Future<void> initialize() async {
    try {
      ErrorService.logInfo('Initializing app state...');

      // Mark as initialized first
      _isInitialized = true;

      // Check device network connectivity first
      await checkNetworkConnectivity();

      // Do quick health check for better UX (non-blocking if it fails)
      // This gives user immediate feedback on backend status
      await checkServiceHealthOnDemand();

      ErrorService.logInfo('App state initialized successfully');
    } catch (e) {
      ErrorService.logError('App initialization failed', error: e);
      // Don't block app startup even if health check fails
      _isInitialized = true;
      _isConnected = false;
      _backendStatus = ServiceStatus.unknown;
      notifyListeners();
    }
  }

  /// Check device network connectivity (WiFi, Mobile, Ethernet)
  /// Distinguishes "device offline" from "backend offline"
  Future<void> checkNetworkConnectivity() async {
    try {
      final List<ConnectivityResult> connectivityResult = await _connectivity
          .checkConnectivity();

      // Check if ANY network connection is available
      _hasNetworkConnection =
          connectivityResult.isNotEmpty &&
          !connectivityResult.contains(ConnectivityResult.none);

      ErrorService.logInfo(
        'Network connectivity check',
        context: {
          'hasConnection': _hasNetworkConnection,
          'types': connectivityResult.map((e) => e.name).join(', '),
        },
      );

      notifyListeners();
    } catch (e) {
      // In test environments, connectivity_plus throws "Binding has not yet been initialized"
      // This is expected and safe to ignore - assume network available in tests
      if (e.toString().contains('Binding has not yet been initialized')) {
        _hasNetworkConnection = true;
      } else {
        ErrorService.logError('Network connectivity check failed', error: e);
        // Fail open: assume network available if check fails
        _hasNetworkConnection = true;
      }
    }
  }

  /// Check backend service health when needed (not during startup)
  Future<void> checkServiceHealthOnDemand() async {
    try {
      // Check device network first
      await checkNetworkConnectivity();

      // If no network, don't even try backend
      if (!_hasNetworkConnection) {
        _backendStatus = ServiceStatus.offline;
        _isConnected = false;
        _connectionError = 'No network connection - Check WiFi or mobile data';
        ErrorService.logWarning('Backend check skipped - no network');
        notifyListeners();
        return;
      }

      final status = await _healthManager.checkBackendHealth();
      _backendStatus = status;
      _healthData = _healthManager.lastHealthData;
      _isConnected = status == ServiceStatus.healthy;
      _connectionError = _isConnected ? null : 'Backend service unavailable';

      ErrorService.logInfo(
        'Service health check completed',
        context: {'status': status.name, 'isConnected': _isConnected},
      );

      notifyListeners();
    } catch (e) {
      _backendStatus = ServiceStatus.offline;
      _isConnected = false;
      _connectionError =
          'Connection failed: ${ErrorService.getUserFriendlyMessage(e)}';
      ErrorService.logError('Service health check failed', error: e);
      notifyListeners();
    }
  }

  /// Retry connection to backend
  Future<void> retryConnection() async {
    _connectionError = null;
    notifyListeners();
    await checkServiceHealthOnDemand();
  }

  /// Clear connection error
  void clearConnectionError() {
    _connectionError = null;
    notifyListeners();
  }
}
