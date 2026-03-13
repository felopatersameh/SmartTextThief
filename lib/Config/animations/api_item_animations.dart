import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension ApiItemAnimationsX on Widget {
  Widget animateApiItem({
    required int index,
    Duration step = const Duration(milliseconds: 70),
    Duration duration = const Duration(milliseconds: 420),
  }) {
    final safeIndex = index < 0 ? 0 : index;
    final boundedIndex = safeIndex > 12 ? 12 + (safeIndex % 3) : safeIndex;
    final delay = Duration(milliseconds: step.inMilliseconds * boundedIndex);

    return animate()
        .fadeIn(
          delay: delay,
          duration: duration,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: 0.08,
          end: 0,
          delay: delay,
          duration: duration,
          curve: Curves.easeOutCubic,
        )
        .scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1, 1),
          delay: delay,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
  }
}
