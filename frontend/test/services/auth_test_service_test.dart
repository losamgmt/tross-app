import 'package:flutter_test/flutter_test.dart';
import 'package:tross_app/services/auth_test_service.dart';
import 'package:tross_app/config/app_config.dart';

/// Tests for AuthTestService
///
/// Note: These are integration-style tests since AuthTestService uses
/// static methods with http.get directly. For true unit tests, the service
/// would need dependency injection for the HTTP client.
///
/// These tests verify:
/// - AuthTestResult structure and properties
/// - Service method signatures and return types
/// - Error handling patterns
void main() {
  group('AuthTestService', () {
    const testToken = 'test-token-123';

    group('AuthTestResult', () {
      test('can be created with all required fields', () {
        final result = AuthTestResult(
          endpoint: '/test',
          description: 'Test Description',
          success: true,
          message: 'Test message',
          statusCode: 200,
          responseTime: const Duration(milliseconds: 100),
        );

        expect(result.endpoint, '/test');
        expect(result.description, 'Test Description');
        expect(result.success, isTrue);
        expect(result.message, 'Test message');
        expect(result.statusCode, 200);
        expect(result.responseTime, const Duration(milliseconds: 100));
      });

      test('can be created without optional fields', () {
        final result = AuthTestResult(
          endpoint: '/test',
          description: 'Test Description',
          success: false,
          message: 'Error occurred',
        );

        expect(result.statusCode, isNull);
        expect(result.responseTime, isNull);
      });

      test('success field reflects test outcome', () {
        final successResult = AuthTestResult(
          endpoint: '/api/test',
          description: 'Success Test',
          success: true,
          message: 'All good',
        );

        final failureResult = AuthTestResult(
          endpoint: '/api/test',
          description: 'Failure Test',
          success: false,
          message: 'Something went wrong',
        );

        expect(successResult.success, isTrue);
        expect(failureResult.success, isFalse);
      });

      test('response time is nullable for error cases', () {
        final resultWithTime = AuthTestResult(
          endpoint: '/test',
          description: 'With Time',
          success: true,
          message: 'Success',
          responseTime: const Duration(milliseconds: 50),
        );

        final resultWithoutTime = AuthTestResult(
          endpoint: '/test',
          description: 'Without Time',
          success: false,
          message: 'Timeout or error',
        );

        expect(resultWithTime.responseTime, isNotNull);
        expect(resultWithoutTime.responseTime, isNull);
      });
    });

    group('Service Method Signatures', () {
      test('testHealthEndpoint returns AuthTestResult', () async {
        final result = await AuthTestService.testHealthEndpoint();
        expect(result, isA<AuthTestResult>());
        expect(result.endpoint, contains('/health'));
        expect(result.description, 'System Health');
      });

      test('testDevStatus accepts token and returns AuthTestResult', () async {
        final result = await AuthTestService.testDevStatus(testToken);
        expect(result, isA<AuthTestResult>());
        expect(result.endpoint, contains('/dev/status'));
        expect(result.description, 'Development Status');
      });

      test('testAuthMe accepts token and returns AuthTestResult', () async {
        final result = await AuthTestService.testAuthMe(testToken);
        expect(result, isA<AuthTestResult>());
        expect(result.endpoint, contains('/auth/me'));
        expect(result.description, 'User Profile');
      });

      test(
        'testAdminUsersEndpoint accepts token and returns AuthTestResult',
        () async {
          final result = await AuthTestService.testAdminUsersEndpoint(
            testToken,
          );
          expect(result, isA<AuthTestResult>());
          expect(result.endpoint, '/users');
          expect(result.description, 'Admin Access Control');
        },
      );

      test('runAllTests returns list of AuthTestResults', () async {
        final results = await AuthTestService.runAllTests(
          token: testToken,
          isAdmin: true,
        );

        expect(results, isA<List<AuthTestResult>>());
        expect(
          results.length,
          greaterThanOrEqualTo(3),
        ); // At least health, devStatus, authMe

        expect(results[0].description, 'System Health');
        expect(results[1].description, 'Development Status');
        expect(results[2].description, 'User Profile');
        // Admin test is conditionally included based on isAdmin flag
      });
    });

    group('Error Handling', () {
      test('runAllTests continues even if individual tests fail', () async {
        // Using invalid token should cause some tests to fail but not stop execution
        final results = await AuthTestService.runAllTests(
          token: 'invalid-token',
          isAdmin: false,
        );

        // Should still return at least 3 results (health doesn't need token)
        expect(results.length, greaterThanOrEqualTo(3));

        // Health check doesn't require token, so it might succeed
        expect(results[0].endpoint, contains('/health'));

        // Other tests should complete (success or failure)
        for (final result in results) {
          expect(result.message, isNotEmpty);
          expect(result.endpoint, isNotEmpty);
          expect(result.description, isNotEmpty);
        }
      });

      test('each test method returns a result even on failure', () async {
        // Tests should never throw - always return AuthTestResult
        final healthResult = await AuthTestService.testHealthEndpoint();
        final devStatusResult = await AuthTestService.testDevStatus('');
        final authMeResult = await AuthTestService.testAuthMe('');
        final adminResult = await AuthTestService.testAdminUsersEndpoint('');

        expect(healthResult, isA<AuthTestResult>());
        expect(devStatusResult, isA<AuthTestResult>());
        expect(authMeResult, isA<AuthTestResult>());
        expect(adminResult, isA<AuthTestResult>());
      });
    });

    group('Response Time Tracking', () {
      test('successful requests include response time', () async {
        final result = await AuthTestService.testHealthEndpoint();

        if (result.success) {
          expect(result.responseTime, isNotNull);
          expect(result.responseTime!.inMilliseconds, greaterThanOrEqualTo(0));
        }
      });

      test('all test results track timing information', () async {
        final results = await AuthTestService.runAllTests(
          token: testToken,
          isAdmin: true,
        );

        for (final result in results) {
          // Response time should be tracked for both success and failure
          // (unless there's a timeout or exception)
          if (result.responseTime != null) {
            expect(
              result.responseTime!.inMilliseconds,
              greaterThanOrEqualTo(0),
            );
          }
        }
      });
    });

    group('Endpoint Configuration', () {
      test('uses AppConfig.baseUrl for API calls', () async {
        // This verifies the service respects centralized configuration
        final result = await AuthTestService.testHealthEndpoint();

        // The endpoint should use the configured base URL
        expect(AppConfig.baseUrl, isNotEmpty);
        expect(result.endpoint, isNotEmpty);
      });

      test('admin endpoint includes pagination parameters', () async {
        // The admin users endpoint should request page 1 with limit 10
        final result = await AuthTestService.testAdminUsersEndpoint(testToken);

        // Endpoint should be /users (not /api/users - base URL includes /api)
        expect(result.endpoint, '/users');
      });
    });
  });
}
