// API Client - Handles authenticated requests to backend
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../config/api_endpoints.dart';
import 'error_service.dart';

class ApiClient {
  // Token refresh callback - set by AuthService
  static Future<String?> Function()? onTokenRefreshNeeded;

  /// Make authenticated request to backend with auto token refresh on 401
  static Future<http.Response> authenticatedRequest(
    String method,
    String endpoint, {
    required String token,
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
    bool isRetry = false, // Prevent infinite retry loops
  }) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      ...?additionalHeaders,
    };

    final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');

    try {
      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(uri, headers: headers)
              .timeout(AppConfig.httpTimeout);
          break;
        case 'POST':
          response = await http
              .post(
                uri,
                headers: headers,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(AppConfig.httpTimeout);
          break;
        case 'PUT':
          response = await http
              .put(
                uri,
                headers: headers,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(AppConfig.httpTimeout);
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: headers)
              .timeout(AppConfig.httpTimeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // Auto token refresh on 401 Unauthorized
      if (response.statusCode == 401 &&
          !isRetry &&
          onTokenRefreshNeeded != null) {
        ErrorService.logInfo('Received 401 - attempting token refresh');

        try {
          final newToken = await onTokenRefreshNeeded!();

          if (newToken != null) {
            ErrorService.logInfo(
              'Token refreshed successfully - retrying request',
            );

            // Retry the original request with new token
            return await authenticatedRequest(
              method,
              endpoint,
              token: newToken,
              body: body,
              additionalHeaders: additionalHeaders,
              isRetry: true, // Prevent double retry
            );
          }
        } catch (e) {
          ErrorService.logError('Token refresh failed', error: e);
          // Fall through to return original 401 response
        }
      }

      return response;
    } catch (e) {
      ErrorService.logError(
        'API request failed',
        error: e,
        context: {'method': method, 'endpoint': endpoint},
      );
      rethrow;
    }
  }

  /// Get user profile from backend
  static Future<Map<String, dynamic>?> getUserProfile(String token) async {
    ErrorService.logInfo('Getting user profile from backend');
    try {
      ErrorService.logInfo('Making GET request to ${ApiEndpoints.authMe}');
      final response = await authenticatedRequest(
        'GET',
        ApiEndpoints.authMe,
        token: token,
      );

      ErrorService.logInfo(
        'User profile response received',
        context: {'statusCode': response.statusCode},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        ErrorService.logInfo(
          'Profile data decoded',
          context: {
            'dataKeys': data.keys.toList(),
            'hasData': data['data'] != null,
          },
        );

        final result = data['data'];
        ErrorService.logInfo(
          'Returning profile',
          context: {'hasProfile': result != null},
        );
        return result;
      } else {
        ErrorService.logError(
          'Failed to fetch user profile',
          error: 'HTTP ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      ErrorService.logError('Error fetching user profile', error: e);
      return null;
    }
  }

  /// Get test token (development only)
  static Future<String?> getTestToken({bool isAdmin = false}) async {
    final endpoint = isAdmin
        ? AppConfig.devAdminTokenEndpoint
        : AppConfig.devTokenEndpoint;

    try {
      final response = await http
          .get(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(AppConfig.httpTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['token'];
      } else {
        ErrorService.logError(
          'Failed to get test token',
          error: 'HTTP ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      ErrorService.logError('Error getting test token', error: e);
      return null;
    }
  }
}
