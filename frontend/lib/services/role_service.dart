/// Role Service - API client for role operations
/// Handles all HTTP requests to /api/roles endpoints
///
/// NOTE: GET /api/roles is public (no auth required)
/// Other operations (create/update/delete) require admin authentication
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/role_model.dart';
import '../config/app_config.dart';

class RoleService {
  /// Get all roles (public endpoint)
  ///
  /// Returns `List<Role>` on success
  /// Throws exception on error with descriptive message
  static Future<List<Role>> getAll() async {
    try {
      // Add pagination params (backend requires them)
      final url = Uri.parse('${AppConfig.backendUrl}/api/roles').replace(
        queryParameters: {
          'page': '1',
          'limit': '100', // Get all roles (there are only 5)
        },
      );

      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw Exception('Request timeout - backend not responding'),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> rolesJson = jsonData['data'];
          return rolesJson.map((json) => Role.fromJson(json)).toList();
        }

        throw Exception('Invalid response format from backend');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch roles');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Get role by ID (public endpoint)
  ///
  /// Returns Role on success
  /// Throws exception if role not found or error occurs
  static Future<Role> getById(int roleId) async {
    try {
      final url = Uri.parse('${AppConfig.backendUrl}/api/roles/$roleId');

      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          return Role.fromJson(jsonData['data']);
        }

        throw Exception('Invalid response format from backend');
      } else if (response.statusCode == 404) {
        throw Exception('Role not found');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch role');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Create new role (admin only)
  ///
  /// Returns created Role on success
  /// Throws exception on error
  static Future<Role> create(String name, String authToken) async {
    try {
      final url = Uri.parse('${AppConfig.backendUrl}/api/roles');

      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: json.encode({'name': name}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          return Role.fromJson(jsonData['data']);
        }

        throw Exception('Invalid response format from backend');
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid role data');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized - Admin access required');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create role');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Update role (admin only)
  ///
  /// Returns updated Role on success
  /// Throws exception on error (including protected roles)
  static Future<Role> update(int roleId, String name, String authToken) async {
    try {
      final url = Uri.parse('${AppConfig.backendUrl}/api/roles/$roleId');

      final response = await http
          .put(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: json.encode({'name': name}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          return Role.fromJson(jsonData['data']);
        }

        throw Exception('Invalid response format from backend');
      } else if (response.statusCode == 403) {
        throw Exception('Cannot modify protected role');
      } else if (response.statusCode == 404) {
        throw Exception('Role not found');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update role');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Delete role (admin only)
  ///
  /// Returns true on success
  /// Throws exception on error (including protected roles or roles in use)
  static Future<bool> delete(int roleId, String authToken) async {
    try {
      final url = Uri.parse('${AppConfig.backendUrl}/api/roles/$roleId');

      final response = await http
          .delete(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 403) {
        throw Exception('Cannot delete protected role');
      } else if (response.statusCode == 409) {
        throw Exception('Role is in use by existing users');
      } else if (response.statusCode == 404) {
        throw Exception('Role not found');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete role');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
