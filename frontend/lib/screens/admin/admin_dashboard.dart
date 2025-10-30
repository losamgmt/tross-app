// Admin Dashboard - Professional Data Tables
// Displays users and roles with sortable, rich-formatted tables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../models/role_model.dart';
import '../../services/user_service.dart';
import '../../services/role_service.dart';
import '../../services/auth_test_service.dart';
import '../../widgets/organisms/organisms.dart' as organisms;
import '../../widgets/molecules/dashboard_card.dart';
import '../../widgets/organisms/dashboards/db_health_dashboard.dart';
import '../../widgets/helpers/async_data_widget.dart';
import '../../widgets/atoms/indicators/loading_indicator.dart';
import '../../config/app_spacing.dart';
import '../../config/app_config.dart';
import 'widgets/user_table_config.dart';
import 'widgets/role_table_config.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Roles state (keeping old pattern for comparison)
  List<Role> _roles = [];
  bool _rolesLoading = true;
  String? _rolesError;

  // Test results for auth testing panel
  final List<String> _testResults = [];
  bool _testsRunning = false;

  // Users future - created once in didChangeDependencies, not in build!
  Future<List<User>>? _usersFuture;

  // Track if we've initialized to prevent duplicate calls during hot reload
  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize data ONCE on first build
    // Hot reload won't trigger this again because _hasInitialized stays true
    if (!_hasInitialized) {
      _hasInitialized = true;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token != null) {
        _usersFuture = UserService.getAll(token);
        _loadRoles();
      }
    }
  }

  Future<List<User>> _reloadUsers() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      throw Exception('No authentication token');
    }

    setState(() {
      _usersFuture = UserService.getAll(token);
    });
    return _usersFuture!;
  }

  /// Run authentication tests using AuthTestService
  Future<void> _runAuthTests() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      setState(() {
        _testResults.clear();
        _testResults.add('❌ Error: No authentication token');
        _testsRunning = false;
      });
      return;
    }

    setState(() {
      _testResults.clear();
      _testsRunning = true;
    });

    try {
      final isAdmin = authProvider.user?['role'] == 'admin';
      final results = await AuthTestService.runAllTests(
        token: token,
        isAdmin: isAdmin,
      );

      if (!mounted) return;

      setState(() {
        _testResults.addAll(results.map((r) => r.toDisplayString()));
        _testsRunning = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _testResults.add('❌ Error running tests: $e');
        _testsRunning = false;
      });
    }
  }

  Future<void> _loadRoles() async {
    setState(() {
      _rolesLoading = true;
      _rolesError = null;
    });

    try {
      final roles = await RoleService.getAll();
      if (mounted) {
        setState(() {
          _roles = roles;
          _rolesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _rolesError = e.toString();
          _rolesLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: const organisms.AppHeader(pageTitle: 'Admin Dashboard'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.lg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 1200;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Database Health (full width)
                DbHealthDashboard.api(
                  apiBaseUrl: AppConfig.backendUrl,
                  authToken: authProvider.token ?? '',
                  autoRefresh: false,
                ),

                spacing.gapLG,

                // Users Table (full width)
                if (_usersFuture != null)
                  AsyncDataWidget<List<User>>(
                    future: _usersFuture!,
                    errorTitle: AppConstants.failedToLoadUsers,
                    onRetry: _reloadUsers,
                    builder: (context, users) {
                      return DashboardCard(
                        child: organisms.AppDataTable<User>(
                          columns: UserTableConfig.getColumns(),
                          data: users,
                          state: users.isEmpty
                              ? organisms.AppDataTableState.empty
                              : organisms.AppDataTableState.loaded,
                          emptyMessage: 'No users found',
                        ),
                      );
                    },
                  )
                else
                  const Center(child: LoadingIndicator.inline()),

                spacing.gapLG,

                // Roles Table (full width)
                DashboardCard(
                  child: organisms.AppDataTable<Role>(
                    columns: RoleTableConfig.getColumns(),
                    data: _roles,
                    state: _rolesLoading
                        ? organisms.AppDataTableState.loading
                        : _rolesError != null
                        ? organisms.AppDataTableState.error
                        : _roles.isEmpty
                        ? organisms.AppDataTableState.empty
                        : organisms.AppDataTableState.loaded,
                    errorMessage: _rolesError,
                    emptyMessage: 'No roles found',
                  ),
                ),

                spacing.gapLG,

                // Bottom Row: Auth Testing + Environment Status (side by side on wide screens)
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      organisms.AuthTestPanel(
                        onRunTests: _runAuthTests,
                        testResults: _testResults,
                        isLoading: _testsRunning,
                      ),
                      SizedBox(width: spacing.lg),
                      // DevelopmentStatusCard deprecated and removed
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      organisms.AuthTestPanel(
                        onRunTests: _runAuthTests,
                        testResults: _testResults,
                        isLoading: _testsRunning,
                      ),
                      spacing.gapLG,
                      // DevelopmentStatusCard deprecated and removed
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
