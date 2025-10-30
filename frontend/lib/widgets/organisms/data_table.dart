/// AppDataTable - Generic table organism
///
/// The main reusable table component that composes all atoms and molecules
/// Type-safe, sortable, filterable, with loading/error/empty states
///
/// Usage:
/// ```dart
/// AppDataTable<User>(
///   columns: [
///     TableColumn.text(
///       id: 'name',
///       label: 'Name',
///       getText: (user) => user.fullName,
///       sortable: true,
///     ),
///   ],
///   data: users,
///   onRowTap: (user) => showDetails(user),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../config/app_spacing.dart';
import '../../config/constants.dart';
import '../../config/table_column.dart';
import '../atoms/typography/column_header.dart';
import '../atoms/containers/scrollable_container.dart';
import '../molecules/table_header.dart';
import '../molecules/table_body.dart';
import '../molecules/empty_state.dart';
import '../molecules/pagination_controls.dart';
import '../molecules/table_toolbar.dart';
import '../atoms/indicators/loading_indicator.dart';

enum AppDataTableState { loading, loaded, error, empty }

class AppDataTable<T> extends StatefulWidget {
  // Data
  final List<T> data;
  final AppDataTableState state;
  final String? errorMessage;

  // Columns
  final List<TableColumn<T>> columns;

  // Interactions
  final void Function(T item)? onRowTap;
  final List<Widget> Function(T item)? actionsBuilder;

  // Toolbar
  final String? title;
  final void Function(String query)? onSearch;
  final List<Widget>? toolbarActions;

  // Pagination
  final bool paginated;
  final int itemsPerPage;
  final int? totalItems;

  // Empty state
  final String? emptyMessage;
  final Widget? emptyAction;

  const AppDataTable({
    super.key,
    required this.columns,
    this.data = const [],
    this.state = AppDataTableState.loaded,
    this.errorMessage,
    this.onRowTap,
    this.actionsBuilder,
    this.title,
    this.onSearch,
    this.toolbarActions,
    this.paginated = false,
    this.itemsPerPage = 10,
    this.totalItems,
    this.emptyMessage,
    this.emptyAction,
  });

  @override
  State<AppDataTable<T>> createState() => _AppDataTableState<T>();
}

class _AppDataTableState<T> extends State<AppDataTable<T>> {
  String? _sortColumnId;
  SortDirection _sortDirection = SortDirection.none;
  int _currentPage = 1;

  List<T> get _displayedData {
    List<T> data = List.from(widget.data);

    // Apply sorting
    if (_sortColumnId != null && _sortDirection != SortDirection.none) {
      final column = widget.columns.firstWhere(
        (col) => col.id == _sortColumnId,
      );
      if (column.comparator != null) {
        data.sort(column.comparator!);
        if (_sortDirection == SortDirection.descending) {
          data = data.reversed.toList();
        }
      }
    }

    // Apply pagination
    if (widget.paginated) {
      final startIndex = (_currentPage - 1) * widget.itemsPerPage;
      final endIndex = startIndex + widget.itemsPerPage;
      if (startIndex < data.length) {
        data = data.sublist(
          startIndex,
          endIndex > data.length ? data.length : endIndex,
        );
      } else {
        data = [];
      }
    }

    return data;
  }

  int get _totalPages {
    if (!widget.paginated) return 1;
    final total = widget.totalItems ?? widget.data.length;
    return (total / widget.itemsPerPage).ceil();
  }

  void _handleSort(String columnId) {
    setState(() {
      if (_sortColumnId == columnId) {
        // Cycle through: none -> ascending -> descending -> none
        _sortDirection = _sortDirection == SortDirection.none
            ? SortDirection.ascending
            : _sortDirection == SortDirection.ascending
            ? SortDirection.descending
            : SortDirection.none;

        if (_sortDirection == SortDirection.none) {
          _sortColumnId = null;
        }
      } else {
        _sortColumnId = columnId;
        _sortDirection = SortDirection.ascending;
      }
    });
  }

  void _handlePageChange(int newPage) {
    setState(() {
      _currentPage = newPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar (with padding)
          if (widget.title != null ||
              widget.onSearch != null ||
              widget.toolbarActions != null)
            Padding(
              padding: EdgeInsets.all(spacing.md),
              child: TableToolbar(
                title: widget.title,
                onSearch: widget.onSearch,
                actions: widget.toolbarActions,
              ),
            ),

          // Table content (NO padding - extends to edges!)
          _buildTableContent(theme),

          // Pagination (with padding)
          if (widget.paginated && widget.state == AppDataTableState.loaded)
            Padding(
              padding: EdgeInsets.all(spacing.md),
              child: PaginationControls(
                currentPage: _currentPage,
                totalPages: _totalPages,
                totalItems: widget.totalItems ?? widget.data.length,
                itemsPerPage: widget.itemsPerPage,
                onPageChanged: _handlePageChange,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableContent(ThemeData theme) {
    // Loading state - simple inline spinner, no text
    if (widget.state == AppDataTableState.loading) {
      return const Center(child: LoadingIndicator.inline());
    }

    // Error state
    if (widget.state == AppDataTableState.error) {
      return EmptyState.error(
        message: widget.errorMessage ?? AppConstants.failedToLoadData,
        action: widget.emptyAction,
      );
    }

    // Empty state
    if (widget.data.isEmpty) {
      return EmptyState.noData(
        message: widget.emptyMessage ?? 'No items to display',
      );
    }

    // Table - fully responsive with visible scrollbar (architectural!)
    return ScrollableContainer.horizontal(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            TableHeader<T>(
              columns: widget.columns,
              sortColumnId: _sortColumnId,
              sortDirection: _sortDirection,
              onSort: _handleSort,
              hasActions: widget.actionsBuilder != null,
            ),

            // Body - constrained to prevent overflow in tests
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 400, // Reasonable max height for table body
              ),
              child: SingleChildScrollView(
                child: TableBody<T>(
                  data: _displayedData,
                  columns: widget.columns,
                  onRowTap: widget.onRowTap,
                  actionsBuilder: widget.actionsBuilder,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
