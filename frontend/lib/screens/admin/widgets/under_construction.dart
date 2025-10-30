/// Under Construction Widget
///
/// Reusable widget for features still in development
/// Can be used for any upcoming admin features
library;

import 'package:flutter/material.dart';

class UnderConstruction extends StatelessWidget {
  final String title;
  final String? message;
  final String? phase;
  final VoidCallback? onBack;

  const UnderConstruction({
    super.key,
    this.title = 'Under Construction',
    this.message,
    this.phase,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: Card(
            elevation: 4,
            color: const Color(0xFFFFB90F).withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Construction Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB90F).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.construction,
                      size: 64,
                      color: Color(0xFFCD7F32), // Bronze
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFCD7F32), // Bronze
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Message
                  if (message != null)
                    Text(
                      message!,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 32),

                  // Progress Indicator
                  LinearProgressIndicator(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFCD7F32), // Bronze
                    ),
                  ),

                  if (phase != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      phase!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],

                  if (onBack != null) ...[
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go Back'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
