/// TableToolbar - Molecule component for table controls
///
/// Combines search, filters, actions above table
/// Flexible layout with common table operations
///
/// Composes: SearchBar, ActionButton atoms
library;

import 'package:flutter/material.dart';
import '../../config/app_spacing.dart';
import 'search_bar.dart' as custom;

class TableToolbar extends StatelessWidget {
  final String? title;
  final ValueChanged<String>? onSearch;
  final List<Widget>? actions;
  final Widget? leading;

  const TableToolbar({
    super.key,
    this.title,
    this.onSearch,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Container(
      padding: spacing.paddingLG,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and actions row
          if (title != null || actions != null || leading != null)
            Padding(
              padding: EdgeInsets.only(bottom: spacing.lg),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    SizedBox(width: spacing.md),
                  ],
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (actions != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children:
                          actions!
                              .expand(
                                (action) => [
                                  action,
                                  SizedBox(width: spacing.sm),
                                ],
                              )
                              .toList()
                            ..removeLast(), // Remove last spacer
                    ),
                ],
              ),
            ),
          // Search bar
          if (onSearch != null)
            custom.SearchBar(placeholder: 'Search...', onSearch: onSearch),
        ],
      ),
    );
  }
}
