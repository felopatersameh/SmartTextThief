import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension StaticAnimationsX on Widget {
  Widget staticReveal({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return animate()
        .fadeIn(
          delay: delay,
          duration: duration,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: 0.06,
          end: 0,
          delay: delay,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
  }

  Widget floatingLoop({
    double begin = 0,
    double end = -8,
    Duration duration = const Duration(milliseconds: 1800),
  }) {
    return animate(onPlay: (controller) => controller.repeat(reverse: true))
        .moveY(
      begin: begin,
      end: end,
      duration: duration,
      curve: Curves.easeInOutSine,
    );
  }

  Widget subtlePulse({
    double begin = 0.98,
    double end = 1.02,
    Duration duration = const Duration(milliseconds: 1700),
  }) {
    return animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
      begin: Offset(begin, begin),
      end: Offset(end, end),
      duration: duration,
      curve: Curves.easeInOutSine,
    );
  }
}
