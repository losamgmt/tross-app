/// AppHeader - Organism for main application navigation bar
///
/// Shared header across all authenticated pages
/// Composes: LogoButton, UserAvatar, UserInfoHeader (atoms)
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_spacing.dart';
import '../../config/app_colors.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth/auth_profile_service.dart';
import '../atoms/buttons/logo_button.dart';
import '../atoms/avatars/user_avatar.dart';
import '../atoms/user_info/user_info_header.dart';
import '../../core/routing/app_routes.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String pageTitle;

  const AppHeader({super.key, required this.pageTitle});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = AuthProfileService.isAdmin(authProvider.user);
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return AppBar(
      backgroundColor: AppColors.brandPrimary,
      foregroundColor: AppColors.white,
      elevation: 2,
      leading: LogoButton(onPressed: () => Navigator.pushNamed(context, '/')),
      leadingWidth: 120,
      title: Text(
        pageTitle,
        style: theme.textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: true,
      actions: [
        // User menu with circular hover effect
        Padding(
          padding: EdgeInsets.only(right: spacing.sm),
          child: PopupMenuButton<String>(
            offset: Offset(0, spacing.xxl * 1.75),
            tooltip: 'User Menu',
            icon: UserAvatar(
              name: authProvider.userName,
              email: authProvider.userEmail,
            ),
            itemBuilder: (context) =>
                _buildMenuItems(context, authProvider, isAdmin),
            onSelected: (value) =>
                _handleMenuSelection(context, value, authProvider),
          ),
        ),
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(
    BuildContext context,
    AuthProvider authProvider,
    bool isAdmin,
  ) {
    return [
      // Profile header (clickable - links to settings)
      PopupMenuItem<String>(
        value: AppConstants.menuProfile,
        padding: EdgeInsets.zero,
        child: UserInfoHeader(
          userName: authProvider.userName,
          userEmail: authProvider.userEmail,
          userRole: authProvider.userRole,
        ),
      ),
      const PopupMenuDivider(),

      // Settings option
      const PopupMenuItem<String>(
        value: AppConstants.menuSettings,
        child: ListTile(
          leading: Icon(Icons.settings, size: 20),
          title: Text('Settings'),
          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacingConst.md),
          dense: true,
        ),
      ),

      // Admin option (only for admins)
      if (isAdmin)
        const PopupMenuItem<String>(
          value: AppConstants.menuAdmin,
          child: ListTile(
            leading: Icon(Icons.admin_panel_settings, size: 20),
            title: Text('Admin Dashboard'),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacingConst.md,
            ),
            dense: true,
          ),
        ),

      const PopupMenuDivider(),

      // Logout option
      const PopupMenuItem<String>(
        value: AppConstants.logout,
        child: ListTile(
          leading: Icon(Icons.logout, size: 20),
          title: Text(AppConstants.logoutButton),
          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacingConst.md),
          dense: true,
        ),
      ),
    ];
  }

  void _handleMenuSelection(
    BuildContext context,
    String value,
    AuthProvider authProvider,
  ) async {
    switch (value) {
      case AppConstants.menuProfile:
      case AppConstants.menuSettings:
        Navigator.pushNamed(context, AppRoutes.settings);
        break;
      case AppConstants.menuAdmin:
        Navigator.pushNamed(context, AppRoutes.admin);
        break;
      case AppConstants.logout:
        // Close popup menu FIRST to prevent deactivated widget error
        Navigator.of(context).pop();

        // Logout and navigate to login page
        await authProvider.logout();

        // Navigate to login using global navigator to avoid context issues
        if (context.mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
        }
        break;
    }
  }
}
