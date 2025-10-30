// Molecule: Error Card - Inline error display for component-level failures
// Use this for partial page failures (e.g., failed to load users list)
// For full-page errors, use ErrorDisplay organism

import 'package:flutter/material.dart';
import '../../config/app_spacing.dart';
import '../../config/app_colors.dart';
import '../../config/app_shadows.dart';
import '../../config/app_borders.dart';
import '../atoms/icons/error_icon.dart';
import 'error_action_buttons.dart';

/// Inline error card for component-level failures
///
/// Unlike ErrorDisplay (full-page), ErrorCard is designed for inline errors
/// within a page - like a failed data load, network timeout, or validation error.
///
/// Usage:
/// ```dart
/// // Simple error
/// ErrorCard(
///   title: 'Failed to Load Users',
///   message: 'Could not connect to server',
/// );
///
/// // With retry action
/// ErrorCard(
///   title: 'Connection Error',
///   message: error.toString(),
///   actions: [
///     ErrorAction.retry(onRetry: (context) async {
///       await _loadData();
///     }),
///   ],
/// );
///
/// // Compact variant (smaller)
/// ErrorCard.compact(
///   message: 'Failed to save changes',
///   onRetry: _saveData,
/// );
/// ```
class ErrorCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final List<ErrorAction>? actions;
  final bool isCompact;
  final EdgeInsets? padding;

  const ErrorCard({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.iconColor,
    this.actions,
    this.isCompact = false,
    this.padding,
  });

  /// Compact error card - minimal space, no icon, inline retry
  factory ErrorCard.compact({
    required String message,
    Future<void> Function(BuildContext)? onRetry,
  }) {
    return ErrorCard(
      title: '',
      message: message,
      isCompact: true,
      actions: onRetry != null
          ? [ErrorAction.retry(onRetry: onRetry, label: 'Retry')]
          : null,
    );
  }

  /// Network error card - standard network failure styling
  factory ErrorCard.network({
    String title = 'Connection Error',
    String message =
        'Unable to connect to server. Please check your internet connection.',
    required Future<void> Function(BuildContext) onRetry,
  }) {
    return ErrorCard(
      title: title,
      message: message,
      icon: Icons.cloud_off_rounded,
      iconColor: AppColors.warning, // Use centralized color
      actions: [ErrorAction.retry(onRetry: onRetry)],
    );
  }

  /// Loading failure card - for data fetch failures
  factory ErrorCard.loadFailed({
    required String resourceName,
    required String error,
    required Future<void> Function(BuildContext) onRetry,
  }) {
    return ErrorCard(
      title: 'Failed to Load $resourceName',
      message: error,
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.error, // Use centralized color
      actions: [ErrorAction.retry(onRetry: onRetry)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    // Compact variant - single line with inline retry
    if (isCompact) {
      return Card(
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: padding ?? EdgeInsets.all(spacing.sm),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 20,
                color: theme.colorScheme.onErrorContainer,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
              if (actions != null && actions!.isNotEmpty) ...[
                SizedBox(width: spacing.sm),
                ErrorActionButtons(actions: actions!),
              ],
            ],
          ),
        ),
      );
    }

    // Standard error card
    return Card(
      elevation: AppShadows.level2, // Use centralized shadow
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.radiusMedium, // Use centralized border radius
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(spacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and title row
            Row(
              children: [
                if (icon != null) ...[
                  ErrorIcon(
                    icon: icon!,
                    color: iconColor ?? theme.colorScheme.error,
                    size: 32,
                  ),
                  SizedBox(width: spacing.sm),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: spacing.sm),

            // Error message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),

            // Actions
            if (actions != null && actions!.isNotEmpty) ...[
              SizedBox(height: spacing.md),
              ErrorActionButtons(actions: actions!),
            ],
          ],
        ),
      ),
    );
  }
}
