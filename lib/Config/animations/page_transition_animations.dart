import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PageTransitionAnimations {
  const PageTransitionAnimations._();
  static const String splashWoodKey = 'splashWoodTransition';

  static bool isSplashWoodExtra(Object? extra) {
    if (extra is! Map) return false;
    final map = Map<String, dynamic>.from(extra);
    return map[splashWoodKey] == true;
  }

  static CustomTransitionPage<T> smooth<T>({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
        final slide = Tween<Offset>(
          begin: const Offset(0.06, 0.02),
          end: Offset.zero,
        ).animate(curve);
        final scale = Tween<double>(begin: 0.985, end: 1.0).animate(curve);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: ScaleTransition(scale: scale, child: child),
          ),
        );
      },
    );
  }

  static CustomTransitionPage<T> woodReveal<T>({
    required GoRouterState state,
    required Widget child,
    int stripCount = 9,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 920),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return AnimatedBuilder(
          animation: curved,
          builder: (context, _) {
            final t = curved.value.clamp(0.0, 1.0);
            return Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: Color.lerp(
                    const Color(0xFF24160D),
                    Colors.transparent,
                    t,
                  )!,
                ),
                ClipPath(
                  clipper: _StripRevealClipper(
                    progress: t,
                    stripCount: stripCount,
                  ),
                  child: FadeTransition(
                    opacity: curved,
                    child: Transform.scale(
                      scale: 0.985 + (0.015 * t),
                      child: child,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StripRevealClipper extends CustomClipper<Path> {
  const _StripRevealClipper({
    required this.progress,
    required this.stripCount,
  });

  final double progress;
  final int stripCount;

  @override
  Path getClip(Size size) {
    final path = Path();
    final total = stripCount < 4 ? 4 : stripCount;
    final stripHeight = size.height / total;
    const stagger = 0.07;
    final maxStart = (total - 1) * stagger;
    final span = 1 - maxStart;

    for (int i = 0; i < total; i++) {
      final start = i * stagger;
      final local = ((progress - start) / span).clamp(0.0, 1.0);
      final eased = Curves.easeOutCubic.transform(local);
      final visibleWidth = size.width * eased;
      if (visibleWidth <= 0) continue;

      final top = stripHeight * i;
      final bottom = top + stripHeight + 0.6;
      if (i.isEven) {
        path.addRect(Rect.fromLTRB(0, top, visibleWidth, bottom));
      } else {
        path.addRect(
          Rect.fromLTRB(size.width - visibleWidth, top, size.width, bottom),
        );
      }
    }

    return path;
  }

  @override
  bool shouldReclip(covariant _StripRevealClipper oldClipper) {
    return oldClipper.progress != progress ||
        oldClipper.stripCount != stripCount;
  }
}
