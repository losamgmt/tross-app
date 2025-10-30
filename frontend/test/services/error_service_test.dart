import 'package:flutter_test/flutter_test.dart';
import 'package:tross_app/services/error_service.dart';

void main() {
  group('ErrorService Tests', () {
    setUp(() {
      // Reset any static state if needed
    });

    group('Error Logging', () {
      test('should log errors without throwing', () {
        expect(() {
          ErrorService.logError('Test error message');
        }, returnsNormally);
      });

      test('should log errors with context without throwing', () {
        expect(() {
          ErrorService.logError(
            'Test error with context',
            context: {'method': 'test', 'user_id': 123},
          );
        }, returnsNormally);
      });

      test('should handle empty error messages gracefully', () {
        expect(() {
          ErrorService.logError('');
        }, returnsNormally);
      });
    });

    group('Warning Logging', () {
      test('should log warning messages without throwing', () {
        expect(() {
          ErrorService.logWarning('Warning message');
        }, returnsNormally);
      });

      test('should handle warnings with context', () {
        expect(() {
          ErrorService.logWarning(
            'Warning with context',
            context: {'operation': 'test'},
          );
        }, returnsNormally);
      });
    });

    group('Info Logging', () {
      test('should log info messages without throwing', () {
        expect(() {
          ErrorService.logInfo('Info message');
        }, returnsNormally);
      });
    });

    group('User-Friendly Messages', () {
      test('should return user-friendly message for null error', () {
        final message = ErrorService.getUserFriendlyMessage(null);
        expect(message, equals('An unexpected error occurred'));
      });

      test('should return network error message for connection issues', () {
        final message = ErrorService.getUserFriendlyMessage(
          'Network connection failed',
        );
        expect(message, contains('Network connection issue'));
      });

      test('should return timeout message for timeout errors', () {
        final message = ErrorService.getUserFriendlyMessage('Request timeout');
        expect(message, contains('Request timed out'));
      });

      test('should return auth error message for unauthorized', () {
        final message = ErrorService.getUserFriendlyMessage(
          'Unauthorized access',
        );
        expect(message, contains('Authentication error'));
      });

      test('should return permission error message', () {
        final message = ErrorService.getUserFriendlyMessage(
          'Permission denied',
        );
        expect(message, contains('Permission denied'));
      });

      test('should return default message for unknown errors', () {
        final message = ErrorService.getUserFriendlyMessage(
          'Some random error',
        );
        expect(message, contains('Something went wrong'));
      });
    });

    group('Edge Cases', () {
      test('should handle very long error messages', () {
        final longMessage = 'x' * 10000;
        expect(() {
          ErrorService.logError(longMessage);
        }, returnsNormally);
      });

      test('should handle complex context objects', () {
        final complexContext = {
          'nested': {
            'level1': {
              'level2': ['array', 'values', 123],
            },
          },
          'numbers': [1, 2, 3, 4, 5],
          'boolean': true,
        };

        expect(() {
          ErrorService.logError(
            'Complex context test',
            context: complexContext,
          );
        }, returnsNormally);
      });
    });
  });
}
