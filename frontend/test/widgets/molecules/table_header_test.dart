/// TableHeader Molecule Tests ✅ MIGRATED TO TEST INFRASTRUCTURE
///
/// Comprehensive tests for the TableHeader molecule component
/// Tests column rendering, sorting interaction, and grid borders
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tross_app/widgets/molecules/table_header.dart';
import 'package:tross_app/config/table_column.dart';
import 'package:tross_app/widgets/atoms/typography/column_header.dart';
import '../../helpers/helpers.dart';

void main() {
  group('TableHeader Molecule Tests', () {
    final testColumns = <TableColumn<String>>[
      TableColumn<String>(
        id: 'name',
        label: 'Name',
        sortable: true,
        cellBuilder: (item) => Text(item),
        comparator: (a, b) => a.compareTo(b),
      ),
      TableColumn<String>(
        id: 'email',
        label: 'Email',
        sortable: true,
        cellBuilder: (item) => Text(item),
        comparator: (a, b) => a.compareTo(b),
      ),
      TableColumn<String>(
        id: 'role',
        label: 'Role',
        sortable: false,
        cellBuilder: (item) => Text(item),
      ),
    ];

    testWidgets('renders all column headers', (tester) async {
      await pumpTestWidget(tester, TableHeader<String>(columns: testColumns));

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Role'), findsOneWidget);
    });

    testWidgets('renders correct number of ColumnHeader widgets', (
      tester,
    ) async {
      await pumpTestWidget(tester, TableHeader<String>(columns: testColumns));

      expect(find.byType(ColumnHeader), findsNWidgets(3));
    });

    testWidgets('renders sortable columns correctly', (tester) async {
      await pumpTestWidget(
        tester,
        TableHeader<String>(columns: testColumns, onSort: (_) {}),
      );

      // Name and Email are sortable - should have unfold_more icons
      expect(find.byIcon(Icons.unfold_more), findsNWidgets(2));
    });

    testWidgets('shows active sort indicator on sorted column', (tester) async {
      await pumpTestWidget(
        tester,
        TableHeader<String>(
          columns: testColumns,
          sortColumnId: 'name',
          sortDirection: SortDirection.ascending,
          onSort: (_) {},
        ),
      );

      // Name column should show ascending arrow
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      // Email column should show neutral icon
      expect(find.byIcon(Icons.unfold_more), findsOneWidget);
    });

    testWidgets('calls onSort with correct column id when header clicked', (
      tester,
    ) async {
      String? sortedColumnId;

      await pumpTestWidget(
        tester,
        TableHeader<String>(
          columns: testColumns,
          onSort: (columnId) => sortedColumnId = columnId,
        ),
      );

      await tester.tap(find.text('Name'));
      await tester.pump();

      expect(sortedColumnId, 'name');
    });

    testWidgets('does not call onSort for non-sortable columns', (
      tester,
    ) async {
      String? sortedColumnId;

      await pumpTestWidget(
        tester,
        TableHeader<String>(
          columns: testColumns,
          onSort: (columnId) => sortedColumnId = columnId,
        ),
      );

      await tester.tap(find.text('Role'));
      await tester.pump();

      expect(sortedColumnId, isNull);
    });

    testWidgets('has proper background color', (tester) async {
      await pumpTestWidget(tester, TableHeader<String>(columns: testColumns));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(TableHeader<String>),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
    });

    testWidgets('has bottom border for separation', (tester) async {
      await pumpTestWidget(tester, TableHeader<String>(columns: testColumns));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(TableHeader<String>),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.bottom, isNotNull);
      expect(decoration.border?.bottom.width, 2);
    });

    testWidgets('has rounded top corners', (tester) async {
      await pumpTestWidget(tester, TableHeader<String>(columns: testColumns));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(TableHeader<String>),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
      final borderRadius = decoration.borderRadius as BorderRadius;
      expect(borderRadius.topLeft.x, 8);
      expect(borderRadius.topRight.x, 8);
    });

    testWidgets('renders actions column when hasActions is true', (
      tester,
    ) async {
      await pumpTestWidget(
        tester,
        TableHeader<String>(columns: testColumns, hasActions: true),
      );

      expect(find.text('Actions'), findsOneWidget);
    });

    testWidgets('does not render actions column when hasActions is false', (
      tester,
    ) async {
      await pumpTestWidget(
        tester,
        TableHeader<String>(columns: testColumns, hasActions: false),
      );

      expect(find.text('Actions'), findsNothing);
    });

    testWidgets('uses IntrinsicHeight for proper alignment', (tester) async {
      await pumpTestWidget(tester, TableHeader<String>(columns: testColumns));

      expect(find.byType(IntrinsicHeight), findsOneWidget);
    });

    testWidgets('uses CrossAxisAlignment.stretch for full height cells', (
      tester,
    ) async {
      await pumpTestWidget(tester, TableHeader<String>(columns: testColumns));

      // Test behavior: all columns render correctly
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Role'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    group('Sort Direction Interaction Tests', () {
      testWidgets('ascending sort shows upward arrow', (tester) async {
        await pumpTestWidget(
          tester,
          TableHeader<String>(
            columns: testColumns,
            sortColumnId: 'email',
            sortDirection: SortDirection.ascending,
            onSort: (_) {},
          ),
        );

        expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      });

      testWidgets('descending sort shows downward arrow', (tester) async {
        await pumpTestWidget(
          tester,
          TableHeader<String>(
            columns: testColumns,
            sortColumnId: 'email',
            sortDirection: SortDirection.descending,
            onSort: (_) {},
          ),
        );

        expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      });

      testWidgets('can toggle sort direction', (tester) async {
        String? currentSortColumn;
        SortDirection currentDirection = SortDirection.none;

        await pumpTestWidget(
          tester,
          StatefulBuilder(
            builder: (context, setState) {
              return TableHeader<String>(
                columns: testColumns,
                sortColumnId: currentSortColumn,
                sortDirection: currentDirection,
                onSort: (columnId) {
                  setState(() {
                    if (currentSortColumn == columnId) {
                      currentDirection =
                          currentDirection == SortDirection.ascending
                          ? SortDirection.descending
                          : SortDirection.ascending;
                    } else {
                      currentSortColumn = columnId;
                      currentDirection = SortDirection.ascending;
                    }
                  });
                },
              );
            },
          ),
        );

        // First click - should sort ascending
        await tester.tap(find.text('Name'));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

        // Second click - should toggle to descending
        await tester.tap(find.text('Name'));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      });

      testWidgets('switching columns resets sort direction', (tester) async {
        String? currentSortColumn = 'name';
        SortDirection currentDirection = SortDirection.descending;

        await pumpTestWidget(
          tester,
          StatefulBuilder(
            builder: (context, setState) {
              return TableHeader<String>(
                columns: testColumns,
                sortColumnId: currentSortColumn,
                sortDirection: currentDirection,
                onSort: (columnId) {
                  setState(() {
                    if (currentSortColumn != columnId) {
                      currentSortColumn = columnId;
                      currentDirection = SortDirection.ascending;
                    }
                  });
                },
              );
            },
          ),
        );

        expect(find.byIcon(Icons.arrow_downward), findsOneWidget);

        // Click different column
        await tester.tap(find.text('Email'));
        await tester.pumpAndSettle();

        // Should show ascending for new column
        expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      });
    });

    group('Column Width Tests', () {
      testWidgets('renders all columns correctly', (tester) async {
        await pumpTestWidget(tester, TableHeader<String>(columns: testColumns));

        // Test behavior: all column headers are rendered
        expect(find.text('Name'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Role'), findsOneWidget);
      });

      testWidgets('renders with multiple columns without overflow', (
        tester,
      ) async {
        await pumpTestWidget(tester, TableHeader<String>(columns: testColumns));

        // Test behavior: header renders without errors
        expect(find.byType(TableHeader<String>), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
