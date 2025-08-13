import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class TimerAnimation extends StatelessWidget {
  final AnimationController controller;

  const TimerAnimation({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CircularProgressIndicator(
          value: controller.value,
          strokeWidth: 4, // Thinner stroke for a refined look
          backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          strokeCap: StrokeCap.round, // Rounded edges for a smoother appearance
        );
      },
    );
  }
}