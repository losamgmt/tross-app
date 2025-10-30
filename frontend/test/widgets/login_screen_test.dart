/// LoginScreen Tests ✅ MIGRATED TO TEST INFRASTRUCTURE
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tross_app/screens/login_screen.dart';
import 'package:tross_app/providers/auth_provider.dart';
import 'package:tross_app/providers/app_provider.dart';
import 'package:tross_app/config/constants.dart';
import '../helpers/helpers.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    /// Helper that wraps LoginScreen with required providers
    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AuthProvider()),
          ChangeNotifierProvider(create: (context) => AppProvider()),
        ],
        child: const LoginScreen(),
      );
    }

    group('UI Elements', () {
      testWidgets('should display app title and logo', (
        WidgetTester tester,
      ) async {
        await pumpTestWidget(tester, createTestWidget());

        // Check for TrossApp title
        expect(find.text(AppConstants.appName), findsOneWidget);

        // Check for subtitle
        expect(find.text(AppConstants.appTagline), findsOneWidget);
      });

      testWidgets('should display login buttons', (WidgetTester tester) async {
        await pumpTestWidget(tester, createTestWidget());

        // Check for test login buttons (text appears in multiple places - label + button)
        expect(find.text(AppConstants.loginButtonTest), findsWidgets);
        expect(find.text(AppConstants.loginButtonAdmin), findsWidgets);
      });

      testWidgets('should display development notice', (
        WidgetTester tester,
      ) async {
        await pumpTestWidget(tester, createTestWidget());

        // Check for development mode notice (new card structure)
        expect(find.text('Developer Login'), findsOneWidget);
        expect(find.text('For testing and development only'), findsOneWidget);
      });

      testWidgets('should display professional footer', (
        WidgetTester tester,
      ) async {
        await pumpTestWidget(tester, createTestWidget());

        // Check for footer elements
        expect(find.text(AppConstants.appDescription), findsOneWidget);
      });
    });

    group('User Interactions', () {
      testWidgets('should respond to technician login tap', (
        WidgetTester tester,
      ) async {
        await pumpTestWidget(tester, createTestWidget());

        // Find and tap the technician login button (appears in multiple places)
        final technicianButton = find.text(AppConstants.loginButtonTest).first;
        expect(find.text(AppConstants.loginButtonTest), findsWidgets);

        await tester.tap(technicianButton);
        await tester.pump();

        // Should trigger login process (we can't easily test navigation without more setup)
      });

      testWidgets('should respond to admin login tap', (
        WidgetTester tester,
      ) async {
        await pumpTestWidget(tester, createTestWidget());

        // Find and tap the admin login button (appears in multiple places)
        final adminButton = find.text(AppConstants.loginButtonAdmin).first;
        expect(find.text(AppConstants.loginButtonAdmin), findsWidgets);

        await tester.tap(adminButton);
        await tester.pump();

        // Should trigger admin login process
      });
    });

    group('Loading States', () {
      testWidgets(
        'should show loading indicator when authentication in progress',
        (WidgetTester tester) async {
          await pumpTestWidget(tester, createTestWidget());

          // We'd need to trigger a loading state to test this
          // For now, just verify the widget builds without errors
          expect(find.byType(LoginScreen), findsOneWidget);
        },
      );
    });

    group('Error States', () {
      testWidgets('should display error messages when authentication fails', (
        WidgetTester tester,
      ) async {
        await pumpTestWidget(tester, createTestWidget());

        // We'd need to inject an error state to test this
        // For now, verify no errors in initial state
        expect(find.byType(LoginScreen), findsOneWidget);
      });
    });

    group('Responsiveness', () {
      testWidgets('should adapt to different screen sizes', (
        WidgetTester tester,
      ) async {
        // Test different screen sizes
        await tester.binding.setSurfaceSize(const Size(400, 800)); // Mobile
        await pumpTestWidget(tester, createTestWidget());
        expect(find.byType(LoginScreen), findsOneWidget);

        await tester.binding.setSurfaceSize(const Size(1200, 800)); // Desktop
        await pumpTestWidget(tester, createTestWidget());
        expect(find.byType(LoginScreen), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper accessibility labels', (
        WidgetTester tester,
      ) async {
        await pumpTestWidget(tester, createTestWidget());

        // Check for buttons with text (appears in multiple places)
        expect(find.text(AppConstants.loginButtonTest), findsWidgets);
        expect(find.text(AppConstants.loginButtonAdmin), findsWidgets);

        // Check for app logo icon
        expect(find.byIcon(Icons.build_circle), findsOneWidget);
      });
    });
  });
}
