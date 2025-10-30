/// UserAvatar - Atom for user profile picture/initials
///
/// Displays user initials in a circular avatar
library;

import 'package:flutter/material.dart';
import '../../../config/app_spacing.dart';
import '../../../config/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final String? email;
  final double? size;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.name,
    this.email,
    this.size,
    this.onTap,
  });

  String get _initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();

    if (parts.isEmpty) {
      // No valid name parts, try email
      if (email != null && email!.isNotEmpty) {
        return email![0].toUpperCase();
      }
      return '?';
    }

    if (parts.length == 1) {
      // Single name, take first character
      return parts[0][0].toUpperCase();
    }

    // Multiple parts, take first char of first and last
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final theme = Theme.of(context);
    final avatarSize = size ?? spacing.xxl * 1.25;

    final avatar = CircleAvatar(
      radius: avatarSize / 2,
      backgroundColor: AppColors.brandPrimary,
      child: Text(
        _initials,
        style: theme.textTheme.titleLarge?.copyWith(
          color: AppColors.white,
          fontSize: avatarSize * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(avatarSize / 2),
        child: avatar,
      );
    }

    return avatar;
  }
}
