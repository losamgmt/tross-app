/// Tests for UiHelpers
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tross_app/utils/helpers/ui_helpers.dart';

void main() {
  group('UiHelpers.showErrorSnackBar', () {
    testWidgets('displays error snackbar with correct message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    UiHelpers.showErrorSnackBar(context, 'Test error message');
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to show snackbar
      await tester.tap(find.text('Show Error'));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 750)); // Finish animation

      // Verify snackbar appears with correct message
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('uses error background color from theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    UiHelpers.showErrorSnackBar(context, 'Error');
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      // Find the SnackBar widget
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));

      // Verify it has a background color (theme.colorScheme.error)
      expect(snackBar.backgroundColor, isNotNull);
    });
  });

  group('UiHelpers.showSuccessSnackBar', () {
    testWidgets('displays success snackbar with correct message', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    UiHelpers.showSuccessSnackBar(context, 'Success!');
                  },
                  child: const Text('Show Success'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Success'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.text('Success!'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('uses green background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    UiHelpers.showSuccessSnackBar(context, 'Success');
                  },
                  child: const Text('Show Success'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Success'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.green);
    });
  });

  group('UiHelpers.showInfoSnackBar', () {
    testWidgets('displays info snackbar with correct message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    UiHelpers.showInfoSnackBar(context, 'Info message');
                  },
                  child: const Text('Show Info'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Info'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.text('Info message'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('uses default background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    UiHelpers.showInfoSnackBar(context, 'Info');
                  },
                  child: const Text('Show Info'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Info'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      // Info snackbar doesn't set backgroundColor, so it should be null
      // (uses default theme-based color)
      expect(snackBar.backgroundColor, isNull);
    });
  });

  group('UiHelpers.showWarningSnackBar', () {
    testWidgets('displays warning snackbar with correct message', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    UiHelpers.showWarningSnackBar(context, 'Warning!');
                  },
                  child: const Text('Show Warning'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Warning'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.text('Warning!'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('uses orange background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    UiHelpers.showWarningSnackBar(context, 'Warning');
                  },
                  child: const Text('Show Warning'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Warning'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.orange);
    });
  });
}
