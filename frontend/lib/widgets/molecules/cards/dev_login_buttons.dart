/// DevLoginButtons - Molecule for development authentication buttons
///
/// Two buttons:
/// - Technician login (secondary color)
/// - Admin login (tertiary color)
///
/// Callbacks handle authentication logic in parent (no business logic here!)
///
/// Atomic Design: Molecule (composed of Button atoms)
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_spacing.dart';
import '../../../config/constants.dart';
import '../../../providers/auth_provider.dart';

class DevLoginButtons extends StatelessWidget {
  /// Callback when technician button pressed
  final VoidCallback onTechnicianPressed;

  /// Callback when admin button pressed
  final VoidCallback onAdminPressed;

  const DevLoginButtons({
    super.key,
    required this.onTechnicianPressed,
    required this.onAdminPressed,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final theme = Theme.of(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Technician Login
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: authProvider.isLoading ? null : onTechnicianPressed,
                icon: const Icon(Icons.build, size: 20),
                label: Text(AppConstants.loginButtonTest),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
              ),
            ),
            SizedBox(height: spacing.md),

            // Admin Login
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: authProvider.isLoading ? null : onAdminPressed,
                icon: const Icon(Icons.admin_panel_settings, size: 20),
                label: Text(AppConstants.loginButtonAdmin),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.tertiary,
                  foregroundColor: theme.colorScheme.onTertiary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
