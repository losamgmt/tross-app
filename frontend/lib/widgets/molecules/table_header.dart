/// TableHeader - Molecule for rendering table header row
///
/// Separates concerns: header rendering and sort logic
/// Composes: ColumnHeader atoms
library;

import 'package:flutter/material.dart';
import '../../config/app_spacing.dart';
import '../../config/table_column.dart';
import '../atoms/typography/column_header.dart';

class TableHeader<T> extends StatelessWidget {
  final List<TableColumn<T>> columns;
  final String? sortColumnId;
  final SortDirection sortDirection;
  final void Function(String columnId)? onSort;
  final bool hasActions;

  const TableHeader({
    super.key,
    required this.columns,
    this.sortColumnId,
    this.sortDirection = SortDirection.none,
    this.onSort,
    this.hasActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outline.withValues(alpha: 0.2);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(bottom: BorderSide(color: borderColor, width: 2)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...columns.asMap().entries.map((entry) {
              final index = entry.key;
              final column = entry.value;
              final isCurrentSort = sortColumnId == column.id;
              final isLastColumn = index == columns.length - 1;

              return Container(
                width: 200, // Fixed width - simple and clean
                constraints: const BoxConstraints(minWidth: 150, maxWidth: 300),
                decoration: BoxDecoration(
                  border: Border(
                    right: !isLastColumn || hasActions
                        ? BorderSide(color: borderColor, width: 1)
                        : BorderSide.none,
                  ),
                ),
                child: ColumnHeader(
                  label: column.label,
                  sortable: column.sortable,
                  sortDirection: isCurrentSort
                      ? sortDirection
                      : SortDirection.none,
                  onSort: column.sortable
                      ? () => onSort?.call(column.id)
                      : null,
                  textAlign: column.alignment,
                ),
              );
            }),
            if (hasActions)
              Container(
                width: 120,
                decoration: BoxDecoration(
                  border: Border(right: BorderSide.none),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacingConst.md,
                    vertical: AppSpacingConst.sm,
                  ),
                  child: Text(
                    'Actions',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
