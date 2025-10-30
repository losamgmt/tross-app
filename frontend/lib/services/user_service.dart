/// User Service - API client for user operations
/// Handles all HTTP requests to /api/users endpoints
///
/// SECURITY: All endpoints require admin authentication
/// Backend validates JWT tokens and admin role
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../config/app_config.dart';

class UserService {
  /// Get all users (admin only)
  ///
  /// Returns `List<User>` on success
  /// Throws exception on error with descriptive message
  static Future<List<User>> getAll(String authToken) async {
    try {
      // Add pagination params (backend requires them)
      final url = Uri.parse('${AppConfig.backendUrl}/api/users').replace(
        queryParameters: {
          'page': '1',
          'limit': '100', // Reasonable default for admin user list
        },
      );

      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw Exception('Request timeout - backend not responding'),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> usersJson = jsonData['data'];
          return usersJson.map((json) => User.fromJson(json)).toList();
        }

        throw Exception('Invalid response format from backend');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized - Admin access required');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch users');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Get user by ID (admin only)
  ///
  /// Returns User on success
  /// Throws exception if user not found or error occurs
  static Future<User> getById(int userId, String authToken) async {
    try {
      final url = Uri.parse('${AppConfig.backendUrl}/api/users/$userId');

      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          return User.fromJson(jsonData['data']);
        }

        throw Exception('Invalid response format from backend');
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized - Admin access required');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch user');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Update user role (admin only)
  ///
  /// Returns updated User on success
  /// Throws exception on error
  static Future<User> updateRole(
    int userId,
    int newRoleId,
    String authToken,
  ) async {
    try {
      final url = Uri.parse('${AppConfig.backendUrl}/api/users/$userId/role');

      final response = await http
          .put(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: json.encode({'role_id': newRoleId}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          return User.fromJson(jsonData['data']);
        }

        throw Exception('Invalid response format from backend');
      } else if (response.statusCode == 403) {
        throw Exception('Cannot modify this user\'s role');
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update user role');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Delete user (admin only)
  ///
  /// Returns true on success
  /// Throws exception on error
  static Future<bool> delete(int userId, String authToken) async {
    try {
      final url = Uri.parse('${AppConfig.backendUrl}/api/users/$userId');

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
        throw Exception('Cannot delete this user');
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete user');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
