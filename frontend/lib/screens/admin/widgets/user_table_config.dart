/// User Table Configuration
///
/// Defines columns and behavior for displaying users in a DataTable
/// Uses atoms/molecules for rich cell rendering
library;

import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../config/table_column.dart';
import '../../../widgets/atoms/atoms.dart';

class UserTableConfig {
  /// Get column definitions for user table
  static List<TableColumn<User>> getColumns({
    List<Widget> Function(User)? actionsBuilder,
  }) {
    return [
      // Name column - reasonable width, not excessive
      TableColumn<User>(
        id: 'name',
        label: 'Name',
        sortable: true,
        width: 2, // Flex ratio: reasonable width for names
        cellBuilder: (user) =>
            DataValue(text: user.fullName, emphasis: ValueEmphasis.primary),
        comparator: (a, b) => a.fullName.compareTo(b.fullName),
      ),

      // Email column - reasonable width, not excessive
      TableColumn<User>(
        id: 'email',
        label: 'Email',
        sortable: true,
        width: 2.5, // Flex ratio: slightly wider for emails (needs more chars)
        cellBuilder: (user) => DataValue.email(user.email),
        comparator: (a, b) => a.email.compareTo(b.email),
      ),

      // Role column - compact for badges
      TableColumn<User>(
        id: 'role',
        label: 'Role',
        sortable: true,
        width: 1.2, // Flex ratio: compact but readable
        cellBuilder: (user) => StatusBadge.role(user.role),
        comparator: (a, b) => a.role.compareTo(b.role),
      ),

      // Status column - compact for badges
      TableColumn<User>(
        id: 'status',
        label: 'Status',
        sortable: true,
        width: 1, // Flex ratio: compact for status badges
        cellBuilder: (user) => StatusBadge(
          label: user.isActive ? 'Active' : 'Inactive',
          style: user.isActive ? BadgeStyle.success : BadgeStyle.neutral,
          compact: true,
        ),
        comparator: (a, b) => a.isActive == b.isActive
            ? 0
            : a.isActive
            ? -1
            : 1,
      ),

      // Created date column - reasonable width
      TableColumn<User>(
        id: 'created',
        label: 'Created',
        sortable: true,
        width: 1.5, // Flex ratio: compact for dates
        cellBuilder: (user) => DataValue.timestamp(user.createdAt),
        comparator: (a, b) => a.createdAt.compareTo(b.createdAt),
      ),
    ];
  }

  /// Filter users by search query
  static List<User> filterUsers(List<User> users, String query) {
    if (query.isEmpty) return users;

    final lowerQuery = query.toLowerCase();
    return users.where((user) {
      return user.fullName.toLowerCase().contains(lowerQuery) ||
          user.email.toLowerCase().contains(lowerQuery) ||
          user.role.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get default sort (by name ascending)
  static int defaultSort(User a, User b) {
    return a.fullName.compareTo(b.fullName);
  }
}
