/// DevLoginCard - Molecule for development authentication
///
/// Self-contained card with:
/// - Header: "Developer Login" with code icon
/// - Description: "For testing and development only"
/// - DevLoginButtons molecule (Technician + Admin buttons)
///
/// Callbacks handle authentication logic in parent
///
/// Atomic Design: Molecule (uses DevLoginButtons molecule)
library;

import 'package:flutter/material.dart';
import '../../../config/app_spacing.dart';
import 'dev_login_buttons.dart';

class DevLoginCard extends StatelessWidget {
  /// Callback when technician button pressed
  final VoidCallback onTechnicianPressed;

  /// Callback when admin button pressed
  final VoidCallback onAdminPressed;

  const DevLoginCard({
    super.key,
    required this.onTechnicianPressed,
    required this.onAdminPressed,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
      child: Padding(
        padding: spacing.paddingXL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dev Card Title
            Row(
              children: [
                Icon(Icons.code, color: theme.colorScheme.error, size: 20),
                SizedBox(width: spacing.sm),
                Text(
                  'Developer Login',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            spacing.gapSM,
            Text(
              'For testing and development only',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            spacing.gapLG,

            // Dev Login Buttons
            DevLoginButtons(
              onTechnicianPressed: onTechnicianPressed,
              onAdminPressed: onAdminPressed,
            ),
          ],
        ),
      ),
    );
  }
}
