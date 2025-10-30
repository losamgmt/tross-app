/// UI Interaction Helpers
///
/// Centralized, reusable utilities for UI interactions like snackbars,
/// dialogs, and notifications.
/// All methods are pure functions with no side effects (except showing UI).
///
/// Single Responsibility: Provide consistent UI feedback mechanisms.
library;

import 'package:flutter/material.dart';

/// UI interaction utilities.
///
/// Provides consistent, reusable UI feedback for:
/// - Error messages (snackbars)
/// - Success messages (snackbars)
/// - Info messages (snackbars)
/// - Dialogs (future enhancement)
class UiHelpers {
  // Private constructor to prevent instantiation
  UiHelpers._();

  /// Shows an error snackbar with red background.
  ///
  /// Displays a Material SnackBar at the bottom of the screen with:
  /// - Error background color (theme.colorScheme.error)
  /// - White text for contrast
  /// - Auto-dismiss after default duration
  ///
  /// Example:
  /// ```dart
  /// UiHelpers.showErrorSnackBar(
  ///   context,
  ///   'Login failed: Invalid credentials',
  /// );
  /// ```
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  /// Shows a success snackbar with green background.
  ///
  /// Displays a Material SnackBar at the bottom of the screen with:
  /// - Success background color (Colors.green)
  /// - White text for contrast
  /// - Auto-dismiss after default duration
  ///
  /// Example:
  /// ```dart
  /// UiHelpers.showSuccessSnackBar(
  ///   context,
  ///   'User created successfully',
  /// );
  /// ```
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  /// Shows an info snackbar with default background.
  ///
  /// Displays a Material SnackBar at the bottom of the screen with:
  /// - Default SnackBar background (theme-based)
  /// - Default text color
  /// - Auto-dismiss after default duration
  ///
  /// Example:
  /// ```dart
  /// UiHelpers.showInfoSnackBar(
  ///   context,
  ///   'Settings saved',
  /// );
  /// ```
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Shows a warning snackbar with amber/orange background.
  ///
  /// Displays a Material SnackBar at the bottom of the screen with:
  /// - Warning background color (Colors.orange)
  /// - Dark text for contrast
  /// - Auto-dismiss after default duration
  ///
  /// Example:
  /// ```dart
  /// UiHelpers.showWarningSnackBar(
  ///   context,
  ///   'Session will expire in 5 minutes',
  /// );
  /// ```
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }
}
