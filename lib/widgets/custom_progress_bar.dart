import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class CustomProgressBar extends StatelessWidget {
  final double progress;
  final Color? color;
  final bool showLabel;

  const CustomProgressBar({
    required this.progress,
    this.color,
    this.showLabel = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progressColor = color ?? colorScheme.primary;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Container(
      height: 12,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Progress Bar
          TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 500),
            tween: Tween<double>(begin: 0, end: clampedProgress),
            builder: (context, value, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FadeTransition(
                    opacity: AlwaysStoppedAnimation(1.0),
                    child: Container(),
                  ),
                ),
              );
            },
          ),
          // Optional Progress Label
          if (showLabel)
            Center(
              child: Text(
                '${(clampedProgress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}