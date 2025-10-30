/// Role Table Configuration
///
/// Defines columns and behavior for displaying roles in a DataTable
/// Uses atoms/molecules for rich cell rendering
library;

import 'package:flutter/material.dart';
import '../../../models/role_model.dart';
import '../../../config/table_column.dart';
import '../../../widgets/atoms/atoms.dart';

class RoleTableConfig {
  /// Get column definitions for role table
  static List<TableColumn<Role>> getColumns({
    List<Widget> Function(Role)? actionsBuilder,
  }) {
    return [
      // Role name column - reasonable width
      TableColumn<Role>(
        id: 'name',
        label: 'Role Name',
        sortable: true,
        width: 2, // Flex ratio: reasonable for role names (not excessive!)
        cellBuilder: (role) => StatusBadge.role(role.name),
        comparator: (a, b) => a.name.compareTo(b.name),
      ),

      // ID column - compact
      TableColumn<Role>(
        id: 'id',
        label: 'ID',
        sortable: true,
        width: 0.8, // Flex ratio: very compact for numeric IDs
        alignment: TextAlign.center,
        cellBuilder: (role) => DataValue.id(role.id.toString()),
        comparator: (a, b) => a.id.compareTo(b.id),
      ),

      // Protected status column - compact
      TableColumn<Role>(
        id: 'protected',
        label: 'Protected',
        sortable: true,
        width: 1.2, // Flex ratio: compact but readable
        cellBuilder: (role) => StatusBadge(
          label: role.isProtected ? 'Yes' : 'No',
          style: role.isProtected ? BadgeStyle.warning : BadgeStyle.neutral,
          icon: role.isProtected ? Icons.lock : Icons.lock_open,
          compact: true,
        ),
        comparator: (a, b) => a.isProtected == b.isProtected
            ? 0
            : a.isProtected
            ? -1
            : 1,
      ),

      // Created date column - reasonable width
      TableColumn<Role>(
        id: 'created',
        label: 'Created',
        sortable: true,
        width: 1.5, // Flex ratio: compact for dates
        cellBuilder: (role) => DataValue.timestamp(role.createdAt),
        comparator: (a, b) => a.createdAt.compareTo(b.createdAt),
      ),
    ];
  }

  /// Filter roles by search query
  static List<Role> filterRoles(List<Role> roles, String query) {
    if (query.isEmpty) return roles;

    final lowerQuery = query.toLowerCase();
    return roles.where((role) {
      return role.name.toLowerCase().contains(lowerQuery) ||
          role.displayName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get default sort (by name ascending)
  static int defaultSort(Role a, Role b) {
    return a.name.compareTo(b.name);
  }
}
