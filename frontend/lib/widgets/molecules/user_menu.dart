/// UserMenu - Molecule for user dropdown menu
///
/// Shows user info and navigation options
library;

import 'package:flutter/material.dart';
import '../../config/app_spacing.dart';
import '../../config/app_colors.dart';

class UserMenu extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userRole;
  final VoidCallback onLogout;
  final VoidCallback onSettings;
  final VoidCallback? onAdmin; // Only for admins

  const UserMenu({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.onLogout,
    required this.onSettings,
    this.onAdmin,
  });

  bool get _isAdmin => userRole.toLowerCase() == 'admin';

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final theme = Theme.of(context);

    return Container(
      width: 280,
      padding: EdgeInsets.symmetric(vertical: spacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User info header
          Padding(
            padding: spacing.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: spacing.xxs),
                Text(
                  userEmail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing.xxs),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.withOpacity(AppColors.brandPrimary, 0.1),
                    borderRadius: spacing.radiusXS,
                  ),
                  child: Text(
                    userRole.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Menu items
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: onSettings,
            dense: true,
          ),

          if (_isAdmin)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin Dashboard'),
              onTap: onAdmin,
              dense: true,
            ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: onLogout,
            dense: true,
          ),
        ],
      ),
    );
  }
}
