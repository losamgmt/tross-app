/// Role Model - Frontend representation of backend Role
/// Backend schema: backend/db/models/Role.js
/// API endpoint: GET /api/roles
/// Last synced: 2025-10-21
///
/// DEFENSIVE: Validates all API response data with toSafe*() validators
/// Philosophy: Never trust external data - validate at every boundary
library;

import '../utils/validators.dart';

class Role {
  final int id;
  final String name;
  final DateTime createdAt;

  Role({required this.id, required this.name, required this.createdAt});

  /// Create Role from JSON response
  ///
  /// DEFENSIVE: Validates all fields with toSafe*() to prevent runtime crashes
  /// Throws ArgumentError with clear field name if data is invalid
  factory Role.fromJson(Map<String, dynamic> json) {
    try {
      return Role(
        id: Validators.toSafeInt(json['id'], 'role.id', min: 1)!,
        name: Validators.toSafeString(
          json['name'],
          'role.name',
          minLength: 3,
          maxLength: 50,
        )!,
        createdAt: Validators.toSafeDateTime(
          json['created_at'],
          'role.created_at',
        )!,
      );
    } catch (e) {
      // Re-throw with context for debugging
      throw ArgumentError('Failed to parse Role from JSON: $e\nJSON: $json');
    }
  }

  /// Convert Role to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'created_at': createdAt.toIso8601String()};
  }

  /// Get display name (capitalized)
  String get displayName {
    if (name.isEmpty) return '';
    return name[0].toUpperCase() + name.substring(1);
  }

  /// Check if role is protected (cannot be deleted/modified)
  bool get isProtected {
    return ['admin', 'client'].contains(name.toLowerCase());
  }

  /// Copy with method for immutable updates
  Role copyWith({int? id, String? name, DateTime? createdAt}) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Role(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Role &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
