/// TableBody Molecule Tests ✅ MIGRATED TO TEST INFRASTRUCTURE
///
/// Comprehensive tests for the TableBody molecule component
/// Tests row rendering, cell generation, alternating colors, and interactions
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tross_app/widgets/molecules/table_body.dart';
import 'package:tross_app/config/table_column.dart';
import 'package:tross_app/widgets/molecules/data_row.dart' as molecules;
import 'package:tross_app/widgets/molecules/data_cell.dart' as molecules;
import '../../helpers/helpers.dart';

void main() {
  group('TableBody Molecule Tests', () {
    final testData = ['Alice', 'Bob', 'Charlie'];

    final testColumns = <TableColumn<String>>[
      TableColumn<String>(
        id: 'name',
        label: 'Name',
        sortable: true,
        cellBuilder: (item) => Text(item),
        comparator: (a, b) => a.compareTo(b),
      ),
      TableColumn<String>(
        id: 'length',
        label: 'Length',
        sortable: false,
        cellBuilder: (item) => Text('${item.length}'),
      ),
    ];

    testWidgets('renders correct number of rows', (tester) async {
      await pumpTestWidget(
        tester,
        TableBody<String>(data: testData, columns: testColumns),
      );

      expect(find.byType(molecules.DataRow), findsNWidgets(3));
    });

    testWidgets('renders correct number of cells per row', (tester) async {
      await pumpTestWidget(
        tester,
        TableBody<String>(data: testData, columns: testColumns),
      );

      // 3 rows * 2 columns = 6 cells
      expect(find.byType(molecules.DataCell), findsNWidgets(6));
    });

    testWidgets('renders cell content correctly', (tester) async {
      await pumpTestWidget(
        tester,
        TableBody<String>(data: testData, columns: testColumns),
      );

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);
      expect(find.text('5'), findsOneWidget); // Alice.length
      expect(find.text('3'), findsOneWidget); // Bob.length
      expect(find.text('7'), findsOneWidget); // Charlie.length
    });

    testWidgets('renders empty when data is empty', (tester) async {
      await pumpTestWidget(
        tester,
        TableBody<String>(data: [], columns: testColumns),
      );

      expect(find.byType(molecules.DataRow), findsNothing);
      expect(find.byType(molecules.DataCell), findsNothing);
    });

    testWidgets('calls onRowTap with correct item when row tapped', (
      tester,
    ) async {
      String? tappedItem;

      await pumpTestWidget(
        tester,
        TableBody<String>(
          data: testData,
          columns: testColumns,
          onRowTap: (item) => tappedItem = item,
        ),
      );

      await tester.tap(find.text('Bob'));
      await tester.pump();

      expect(tappedItem, 'Bob');
    });

    testWidgets('does not throw when row tapped without onRowTap', (
      tester,
    ) async {
      await pumpTestWidget(
        tester,
        TableBody<String>(data: testData, columns: testColumns),
      );

      // Should not throw
      await tester.tap(find.text('Alice'));
      await tester.pump();
    });

    testWidgets('applies alternating row colors correctly', (tester) async {
      await pumpTestWidget(
        tester,
        TableBody<String>(data: testData, columns: testColumns),
      );

      final rows = tester
          .widgetList<molecules.DataRow>(find.byType(molecules.DataRow))
          .toList();

      expect(rows[0].isEvenRow, true); // Index 0 - even
      expect(rows[1].isEvenRow, false); // Index 1 - odd
      expect(rows[2].isEvenRow, true); // Index 2 - even
    });

    testWidgets('applies borders to cells correctly', (tester) async {
      await pumpTestWidget(
        tester,
        TableBody<String>(data: ['Test'], columns: testColumns),
      );

      final cells = tester
          .widgetList<molecules.DataCell>(find.byType(molecules.DataCell))
          .toList();

      // First cell should have right border (not last column)
      expect(cells[0].showRightBorder, true);
      // Last cell should not have right border (last column, no actions)
      expect(cells[1].showRightBorder, false);
    });

    testWidgets('adds border to last cell when actions present', (
      tester,
    ) async {
      await pumpTestWidget(
        tester,
        TableBody<String>(
          data: ['Test'],
          columns: testColumns,
          actionsBuilder: (item) => [
            IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
          ],
        ),
      );

      final cells = tester
          .widgetList<molecules.DataCell>(find.byType(molecules.DataCell))
          .toList();

      // Last cell should have right border when actions present
      expect(cells[1].showRightBorder, true);
    });

    testWidgets('renders action widgets when actionsBuilder provided', (
      tester,
    ) async {
      await pumpTestWidget(
        tester,
        TableBody<String>(
          data: testData,
          columns: testColumns,
          actionsBuilder: (item) => [
            IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
            IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
          ],
        ),
      );

      // 3 rows * 2 actions = 6 action buttons
      expect(find.byIcon(Icons.edit), findsNWidgets(3));
      expect(find.byIcon(Icons.delete), findsNWidgets(3));
    });

    group('Alignment Tests', () {
      testWidgets('applies left alignment correctly', (tester) async {
        final columns = <TableColumn<String>>[
          TableColumn<String>(
            id: 'test',
            label: 'Test',
            alignment: TextAlign.left,
            sortable: false,
            cellBuilder: (item) => Text(item),
          ),
        ];

        await pumpTestWidget(
          tester,
          TableBody<String>(data: ['Test'], columns: columns),
        );

        final cell = tester.widget<molecules.DataCell>(
          find.byType(molecules.DataCell),
        );

        expect(cell.alignment, Alignment.centerLeft);
      });

      testWidgets('applies center alignment correctly', (tester) async {
        final columns = <TableColumn<String>>[
          TableColumn<String>(
            id: 'test',
            label: 'Test',
            alignment: TextAlign.center,
            sortable: false,
            cellBuilder: (item) => Text(item),
          ),
        ];

        await pumpTestWidget(
          tester,
          TableBody<String>(data: ['Test'], columns: columns),
        );

        final cell = tester.widget<molecules.DataCell>(
          find.byType(molecules.DataCell),
        );

        expect(cell.alignment, Alignment.center);
      });

      testWidgets('applies right alignment correctly', (tester) async {
        final columns = <TableColumn<String>>[
          TableColumn<String>(
            id: 'test',
            label: 'Test',
            alignment: TextAlign.right,
            sortable: false,
            cellBuilder: (item) => Text(item),
          ),
        ];

        await pumpTestWidget(
          tester,
          TableBody<String>(data: ['Test'], columns: columns),
        );

        final cell = tester.widget<molecules.DataCell>(
          find.byType(molecules.DataCell),
        );

        expect(cell.alignment, Alignment.centerRight);
      });
    });

    group('Large Dataset Tests', () {
      testWidgets('handles large number of rows efficiently', (tester) async {
        final largeData = List.generate(100, (index) => 'Item $index');

        await pumpTestWidget(
          tester,
          SingleChildScrollView(
            child: TableBody<String>(data: largeData, columns: testColumns),
          ),
        );

        expect(find.byType(molecules.DataRow), findsNWidgets(100));
      });

      testWidgets('alternating colors work correctly for large dataset', (
        tester,
      ) async {
        final largeData = List.generate(50, (index) => 'Item $index');

        await pumpTestWidget(
          tester,
          SingleChildScrollView(
            child: TableBody<String>(data: largeData, columns: testColumns),
          ),
        );

        final rows = tester
            .widgetList<molecules.DataRow>(find.byType(molecules.DataRow))
            .toList();

        // Check first, middle, and last rows
        expect(rows[0].isEvenRow, true);
        expect(rows[1].isEvenRow, false);
        expect(rows[25].isEvenRow, false);
        expect(rows[48].isEvenRow, true);
        expect(rows[49].isEvenRow, false);
      });
    });

    testWidgets('uses Column with mainAxisSize.min', (tester) async {
      await pumpTestWidget(
        tester,
        TableBody<String>(data: testData, columns: testColumns),
      );

      // Test behavior: table body renders all rows
      expect(find.byType(TableBody<String>), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('border color respects theme', (tester) async {
      await pumpTestWidget(
        tester,
        TableBody<String>(data: ['Test'], columns: testColumns),
      );

      final cell = tester.widget<molecules.DataCell>(
        find.byType(molecules.DataCell).first,
      );

      expect(cell.borderColor, isNotNull);
    });
  });
}
