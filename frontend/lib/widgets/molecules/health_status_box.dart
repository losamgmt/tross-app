import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../atoms/buttons/refresh_icon_button.dart';

class HealthStatusBox extends StatelessWidget {
  final VoidCallback onRefresh;
  final Widget? child;
  final String? subtitle;
  final bool isRefreshing;
  const HealthStatusBox({
    super.key,
    required this.onRefresh,
    this.child,
    this.subtitle,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Database Health',
                    style: StyleConstants.healthBoxTitleStyle,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            isRefreshing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : RefreshIconButton(onPressed: onRefresh),
          ],
        ),
        if (child != null) ...[
          SizedBox(height: StyleConstants.healthBoxSpacing),
          child!,
        ],
      ],
    );
  }
}
