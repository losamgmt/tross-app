/// DataRow - Molecule component for table row
///
/// Row of cells with hover effect, selection, and actions
/// Handles responsive behavior and interactions
///
/// Composes: DataCell molecules
library;

import 'package:flutter/material.dart';
import '../../config/app_spacing.dart';

class DataRow extends StatefulWidget {
  final List<Widget> cells;
  final List<int>?
  flexValues; // Column widths (not flex anymore, actual widths)
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final List<Widget>? actions;
  final bool isEvenRow;

  const DataRow({
    super.key,
    required this.cells,
    this.flexValues,
    this.selected = false,
    this.onTap,
    this.onLongPress,
    this.actions,
    this.isEvenRow = false,
  });

  @override
  State<DataRow> createState() => _DataRowState();
}

class _DataRowState extends State<DataRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color? backgroundColor;
    if (widget.selected) {
      backgroundColor = theme.colorScheme.primaryContainer.withValues(
        alpha: 0.3,
      );
    } else if (_isHovered) {
      backgroundColor = theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.3,
      );
    } else if (widget.isEvenRow) {
      backgroundColor = theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.05,
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fixed width cells matching headers
              ...widget.cells.asMap().entries.map((entry) {
                final cell = entry.value;
                return Container(
                  width: 200, // Fixed width matching header
                  constraints: const BoxConstraints(
                    minWidth: 150,
                    maxWidth: 300,
                  ),
                  child: cell,
                );
              }),
              if (widget.actions != null && widget.actions!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.spacing.sm),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        widget.actions!
                            .expand(
                              (action) => [
                                action,
                                SizedBox(width: context.spacing.xxs),
                              ],
                            )
                            .toList()
                          ..removeLast(), // Remove last spacer
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
