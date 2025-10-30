/// LoginScreen - Pure atomic composition, ZERO business logic
///
/// Composition:
/// - LoginHeader molecule (branding)
/// - ProductionLoginCard molecule (Auth0)
/// - DevLoginCard molecule (dev auth, conditional)
/// - ConnectionStatusBadge atom (backend health)
/// - AppFooter molecule (copyright)
///
/// Business logic: Handled via callbacks to AuthProvider
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../config/app_config.dart';
import '../config/constants.dart';
import '../config/app_spacing.dart';
import '../services/error_service.dart';
import '../utils/helpers/ui_helpers.dart';
import '../widgets/molecules/login_header.dart';
import '../widgets/molecules/cards/production_login_card.dart';
import '../widgets/molecules/cards/dev_login_card.dart';
import '../widgets/atoms/atoms.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Scaffold(
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth > 800;

                return Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isWideScreen ? 500 : constraints.maxWidth * 0.9,
                    ),
                    child: SingleChildScrollView(
                      padding: spacing.paddingXL,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Branding
                          const LoginHeader(
                            title: AppConstants.appName,
                            subtitle: AppConstants.appTagline,
                          ),

                          spacing.gapXXXL,

                          // Production Auth0 login
                          const ProductionLoginCard(),

                          // Dev authentication (conditional)
                          if (AppConfig.isDevMode) ...[
                            spacing.gapXL,
                            DevLoginCard(
                              onTechnicianPressed: () =>
                                  _handleDevLogin(context, isAdmin: false),
                              onAdminPressed: () =>
                                  _handleDevLogin(context, isAdmin: true),
                            ),
                          ],

                          spacing.gapXXXL,

                          // Backend health status
                          ConnectionStatusBadge.connection(
                            isConnected: appProvider.isBackendHealthy,
                          ),

                          spacing.gapXL,

                          // Footer
                          const AppFooter(
                            copyright: AppConstants.appCopyright,
                            description: AppConstants.appDescription,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Handle dev authentication (technician or admin)
  Future<void> _handleDevLogin(
    BuildContext context, {
    required bool isAdmin,
  }) async {
    if (!context.mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    ErrorService.logInfo('Starting dev login', context: {'isAdmin': isAdmin});

    try {
      final success = await authProvider.loginWithTestToken(isAdmin: isAdmin);

      ErrorService.logInfo(
        'Dev login result',
        context: {
          'success': success,
          'isAuthenticated': authProvider.isAuthenticated,
          'isAdmin': isAdmin,
        },
      );

      if (!context.mounted) return;

      if (success) {
        ErrorService.logInfo(
          'Login successful - navigating to home',
          context: {'route': AppConstants.homeRoute},
        );
        Navigator.of(context).pushReplacementNamed(AppConstants.homeRoute);
      } else {
        ErrorService.logWarning(
          '[Expected in tests] Login failed - showing error to user',
          context: {'isAdmin': isAdmin},
        );
        UiHelpers.showErrorSnackBar(
          context,
          isAdmin
              ? AppConstants.adminLoginFailed
              : AppConstants.technicianLoginFailed,
        );
      }
    } catch (e) {
      ErrorService.logError(
        'Login exception',
        error: e,
        context: {'isAdmin': isAdmin},
      );
      if (context.mounted) {
        final role = isAdmin ? 'Admin' : 'Technician';
        UiHelpers.showErrorSnackBar(context, '$role login failed: $e');
      }
    }
  }
}
