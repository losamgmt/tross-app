/// User Model - Frontend representation of backend User
/// Backend schema: backend/db/models/User.js
/// API endpoint: GET /api/users
/// Last synced: 2025-10-21
///
/// DEFENSIVE: Validates all API response data with toSafe*() validators
/// Philosophy: Never trust external data - validate at every boundary
library;

import '../utils/validators.dart';

class User {
  final int id;
  final String email;
  final String auth0Id;
  final String firstName;
  final String lastName;
  final int roleId;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.auth0Id,
    required this.firstName,
    required this.lastName,
    required this.roleId,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create User from JSON response
  ///
  /// DEFENSIVE: Validates all fields with toSafe*() to prevent runtime crashes
  /// Throws ArgumentError with clear field name if data is invalid
  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: Validators.toSafeInt(json['id'], 'user.id', min: 1)!,
        email: Validators.toSafeEmail(json['email'], 'user.email'),
        auth0Id: Validators.toSafeString(json['auth0_id'], 'user.auth0_id')!,
        firstName:
            Validators.toSafeString(
              json['first_name'],
              'user.first_name',
              allowNull: true,
            ) ??
            '',
        lastName:
            Validators.toSafeString(
              json['last_name'],
              'user.last_name',
              allowNull: true,
            ) ??
            '',
        roleId: Validators.toSafeInt(json['role_id'], 'user.role_id', min: 1)!,
        role: Validators.toSafeString(json['role'], 'user.role', minLength: 3)!,
        isActive:
            Validators.toSafeBool(json['is_active'], 'user.is_active') ?? true,
        createdAt: Validators.toSafeDateTime(
          json['created_at'],
          'user.created_at',
        )!,
        updatedAt: Validators.toSafeDateTime(
          json['updated_at'],
          'user.updated_at',
        )!,
      );
    } catch (e) {
      // Re-throw with context for debugging
      throw ArgumentError('Failed to parse User from JSON: $e\nJSON: $json');
    }
  }

  /// Convert User to JSON (for updates/creates)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'auth0_id': auth0Id,
      'first_name': firstName,
      'last_name': lastName,
      'role_id': roleId,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Get user's full name
  String get fullName {
    final first = firstName.trim();
    final last = lastName.trim();

    if (first.isEmpty && last.isEmpty) {
      return email.split('@').first; // Fallback to email username
    }

    return '$first $last'.trim();
  }

  /// Get user's display name (for UI)
  String get displayName => fullName;

  /// Copy with method for immutable updates
  User copyWith({
    int? id,
    String? email,
    String? auth0Id,
    String? firstName,
    String? lastName,
    int? roleId,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      auth0Id: auth0Id ?? this.auth0Id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      roleId: roleId ?? this.roleId,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'User(id: $id, email: $email, role: $role)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
