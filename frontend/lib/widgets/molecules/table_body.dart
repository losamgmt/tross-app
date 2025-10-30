/// TableBody - Molecule for rendering table rows
///
/// Separates concerns: table body rendering logic
/// Composes: DataRow molecules
library;

import 'package:flutter/material.dart';
import '../../config/table_column.dart';
import 'data_cell.dart' as molecules;
import 'data_row.dart' as molecules;

class TableBody<T> extends StatelessWidget {
  final List<T> data;
  final List<TableColumn<T>> columns;
  final void Function(T item)? onRowTap;
  final List<Widget> Function(T item)? actionsBuilder;

  const TableBody({
    super.key,
    required this.data,
    required this.columns,
    this.onRowTap,
    this.actionsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outline.withValues(alpha: 0.2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isEvenRow = index % 2 == 0;

        // Extract flex values from columns to pass to DataRow
        final flexValues = columns
            .map((col) => col.width?.toInt() ?? 1)
            .toList();

        return molecules.DataRow(
          cells: columns.asMap().entries.map((colEntry) {
            final colIndex = colEntry.key;
            final column = colEntry.value;
            final isLastColumn = colIndex == columns.length - 1;

            return molecules.DataCell(
              alignment: _getAlignment(column.alignment),
              showRightBorder: !isLastColumn || actionsBuilder != null,
              borderColor: borderColor,
              child: column.cellBuilder(item),
            );
          }).toList(),
          flexValues: flexValues, // Pass flex values for alignment
          onTap: onRowTap != null ? () => onRowTap!(item) : null,
          actions: actionsBuilder?.call(item),
          isEvenRow: isEvenRow,
        );
      }).toList(),
    );
  }

  Alignment _getAlignment(TextAlign textAlign) {
    switch (textAlign) {
      case TextAlign.left:
      case TextAlign.start:
        return Alignment.centerLeft;
      case TextAlign.right:
      case TextAlign.end:
        return Alignment.centerRight;
      case TextAlign.center:
        return Alignment.center;
      default:
        return Alignment.centerLeft;
    }
  }
}
