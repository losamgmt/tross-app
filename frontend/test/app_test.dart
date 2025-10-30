/// App Tests ✅ MIGRATED TO TEST INFRASTRUCTURE
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tross_app/main.dart';
import 'package:tross_app/config/constants.dart';
import 'helpers/helpers.dart';

void main() {
  testWidgets('TrossApp loads without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await pumpTestWidget(tester, const TrossApp());

    // Instead of pumpAndSettle (which waits for all async to complete),
    // let's pump a few frames to allow initial rendering
    await tester.pump();
    await tester.pump();

    // Verify the app starts loading (shows initialization screen)
    expect(find.text('Initializing Tross...'), findsOneWidget);

    // Wait a bit more for providers to potentially complete initialization
    // If HTTP calls complete quickly in isolation, this should work
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    // The app should either show login screen or still be initializing
    // Both are valid states - the key is that it didn't crash
    final hasAppName = find.text(AppConstants.appName);
    final hasInitializing = find.text('Initializing Tross...');

    // At least one of these should be present (app loaded or still loading)
    expect(
      hasAppName.evaluate().isNotEmpty || hasInitializing.evaluate().isNotEmpty,
      isTrue,
      reason: 'App should show either loading state or main content',
    );

    // Verify the app doesn't crash
    expect(tester.takeException(), isNull);
  });

  testWidgets('TrossApp can handle initialization gracefully', (
    WidgetTester tester,
  ) async {
    // This test focuses on graceful initialization handling
    await pumpTestWidget(tester, const TrossApp());
    await tester.pump();

    // Should show loading initially
    expect(find.text('Initializing Tross...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Test that the app doesn't crash during initialization
    // We'll pump a few times and verify it remains stable
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));

      // Should still have either loading or loaded content
      final hasLoading = find
          .text('Initializing Tross...')
          .evaluate()
          .isNotEmpty;
      final hasContent = find.text(AppConstants.appName).evaluate().isNotEmpty;

      expect(
        hasLoading || hasContent,
        isTrue,
        reason:
            'App should maintain valid state during initialization (iteration $i)',
      );
    }
  });
}
