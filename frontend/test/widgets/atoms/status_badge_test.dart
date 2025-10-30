/// StatusBadge Atom Tests
///
/// Comprehensive tests for the StatusBadge atom component
/// Tests rendering, styling, role factory, and variants
/// ✅ MIGRATED: Uses test infrastructure (helpers, spacing)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tross_app/widgets/atoms/atoms.dart';
import '../../helpers/helpers.dart';

void main() {
  group('StatusBadge Atom Tests', () {
    testWidgets('renders with required label', (tester) async {
      await pumpTestWidget(tester, const StatusBadge(label: 'Test Label'));

      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('renders with icon when provided', (tester) async {
      await pumpTestWidget(
        tester,
        const StatusBadge(label: 'With Icon', icon: Icons.star),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });

    testWidgets('renders compact variant correctly', (tester) async {
      await pumpTestWidget(
        tester,
        const StatusBadge(label: 'Compact', compact: true),
      );

      expectContainerPadding(
        tester,
        find.text('Compact'),
        EdgeInsets.symmetric(
          horizontal: TestSpacing.sm,
          vertical: TestSpacing.xxs,
        ),
      );
    });

    testWidgets('renders normal variant correctly', (tester) async {
      await pumpTestWidget(
        tester,
        const StatusBadge(label: 'Normal', compact: false),
      );

      expectContainerPadding(
        tester,
        find.text('Normal'),
        EdgeInsets.symmetric(
          horizontal: TestSpacing.md,
          vertical: TestSpacing.xs,
        ),
      );
    });

    group('Role Factory Tests', () {
      testWidgets('creates Admin badge with correct styling', (tester) async {
        await pumpTestWidget(tester, StatusBadge.role('admin'));

        expect(find.text('Admin'), findsOneWidget);
        expect(find.byIcon(Icons.admin_panel_settings), findsOneWidget);
      });

      testWidgets('creates Technician badge with correct styling', (
        tester,
      ) async {
        await pumpTestWidget(tester, StatusBadge.role('technician'));

        expect(find.text('Technician'), findsOneWidget);
        expect(find.byIcon(Icons.build), findsOneWidget);
      });

      testWidgets('creates Manager badge with correct styling', (tester) async {
        await pumpTestWidget(tester, StatusBadge.role('manager'));

        expect(find.text('Manager'), findsOneWidget);
        expect(find.byIcon(Icons.business_center), findsOneWidget);
      });

      testWidgets('creates Dispatcher badge with correct styling', (
        tester,
      ) async {
        await pumpTestWidget(tester, StatusBadge.role('dispatcher'));

        expect(find.text('Dispatcher'), findsOneWidget);
        expect(find.byIcon(Icons.route), findsOneWidget);
      });

      testWidgets('creates Client badge with correct styling', (tester) async {
        await pumpTestWidget(tester, StatusBadge.role('client'));

        expect(find.text('Client'), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
      });

      testWidgets('handles unknown role with neutral styling', (tester) async {
        await pumpTestWidget(tester, StatusBadge.role('unknown'));

        expect(find.text('Unknown'), findsOneWidget);
        expect(find.byIcon(Icons.label), findsOneWidget);
      });

      testWidgets('capitalizes role name', (tester) async {
        await pumpTestWidget(tester, StatusBadge.role('admin'));

        expect(find.text('Admin'), findsOneWidget);
        expect(find.text('admin'), findsNothing);
      });
    });

    group('Style Variants Tests', () {
      testWidgets('applies success style', (tester) async {
        await pumpTestWidget(
          tester,
          const StatusBadge(label: 'Success', style: BadgeStyle.success),
        );

        expect(find.text('Success'), findsOneWidget);
      });

      testWidgets('applies warning style', (tester) async {
        await pumpTestWidget(
          tester,
          const StatusBadge(label: 'Warning', style: BadgeStyle.warning),
        );

        expect(find.text('Warning'), findsOneWidget);
      });

      testWidgets('applies error style', (tester) async {
        await pumpTestWidget(
          tester,
          const StatusBadge(label: 'Error', style: BadgeStyle.error),
        );

        expect(find.text('Error'), findsOneWidget);
      });

      testWidgets('applies info style', (tester) async {
        await pumpTestWidget(
          tester,
          const StatusBadge(label: 'Info', style: BadgeStyle.info),
        );

        expect(find.text('Info'), findsOneWidget);
      });

      testWidgets('applies neutral style (default)', (tester) async {
        await pumpTestWidget(
          tester,
          const StatusBadge(label: 'Neutral', style: BadgeStyle.neutral),
        );

        expect(find.text('Neutral'), findsOneWidget);
      });
    });

    testWidgets('has proper border radius', (tester) async {
      await pumpTestWidget(tester, const StatusBadge(label: 'Test'));

      final container = tester.widget<Container>(
        find.ancestor(of: find.text('Test'), matching: find.byType(Container)),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(TestSpacing.md));
    });

    testWidgets('compact variant has smaller border radius', (tester) async {
      await pumpTestWidget(
        tester,
        const StatusBadge(label: 'Test', compact: true),
      );

      final container = tester.widget<Container>(
        find.ancestor(of: find.text('Test'), matching: find.byType(Container)),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(TestSpacing.sm));
    });

    testWidgets('has border decoration', (tester) async {
      await pumpTestWidget(tester, const StatusBadge(label: 'Test'));

      final container = tester.widget<Container>(
        find.ancestor(of: find.text('Test'), matching: find.byType(Container)),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });
  });
}
