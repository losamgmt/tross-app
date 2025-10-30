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
import '../../widgets/organisms/dashboards/db_health_dashboard.dart';
import '../../widgets/helpers/async_data_widget.dart';
import '../../config/table_config.dart';
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

  // Key for AsyncDataWidget to force reload
  final int _usersReloadKey = 0;

  @override
  void initState() {
    super.initState();
    _loadRoles();
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

  /// Load users - NEW Flutter-native AsyncDataWidget pattern!
  Future<List<User>> _loadUsers() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      throw Exception('No authentication token');
    }

    // UserService.getAll throws exceptions on error - AsyncDataWidget catches them!
    return await UserService.getAll(token);
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
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: const organisms.AppHeader(pageTitle: 'Admin Dashboard'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Database Health Card
            _buildSectionCard(
              theme: theme,
              title: 'Database Health',
              icon: Icons.storage,
              subtitle: 'Monitor system health and connectivity',
              child: DbHealthDashboard.api(
                apiBaseUrl: AppConfig.backendUrl,
                authToken: authProvider.token ?? '',
                autoRefresh: false,
              ),
            ),

            spacing.gapLG,

            // Users Card
            _buildSectionCard(
              theme: theme,
              title: 'Users',
              icon: Icons.people,
              subtitle: 'Manage user accounts and permissions',
              child: AsyncDataWidget<List<User>>(
                key: ValueKey(_usersReloadKey),
                future: _loadUsers(),
                errorTitle: AppConstants.failedToLoadUsers,
                onRetry: _loadUsers,
                builder: (context, users) {
                  return SizedBox(
                    height:
                        TableConfig.calculateTableHeight(users.length) ??
                        TableConfig.minTableHeight,
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
              ),
            ),

            spacing.gapLG,

            // Roles Card
            _buildSectionCard(
              theme: theme,
              title: 'Roles',
              icon: Icons.admin_panel_settings,
              subtitle: 'View and manage role configurations',
              child: SizedBox(
                height:
                    TableConfig.calculateTableHeight(_roles.length) ??
                    TableConfig.minTableHeight,
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
            ),

            spacing.gapLG,

            // Development Tools Card
            _buildSectionCard(
              theme: theme,
              title: 'Development Tools',
              icon: Icons.build,
              subtitle: 'Testing and environment diagnostics',
              child: Column(
                children: [
                  organisms.AuthTestPanel(
                    onRunTests: _runAuthTests,
                    testResults: _testResults,
                    isLoading: _testsRunning,
                  ),
                  spacing.gapMD,
                  const organisms.DevelopmentStatusCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build elegant section card with consistent styling
  Widget _buildSectionCard({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required String subtitle,
    required Widget child,
  }) {
    final spacing = context.spacing;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(spacing.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 24, color: theme.colorScheme.primary),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: spacing.xxs),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            // Card Content
            child,
          ],
        ),
      ),
    );
  }
}
