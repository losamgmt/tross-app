import 'package:flutter/material.dart';
import '../../../config/constants.dart';

class RefreshIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  const RefreshIconButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.refresh, size: StyleConstants.iconSizeSmall),
      tooltip: 'Refresh',
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
