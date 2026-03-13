import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Config/animations/page_transition_animations.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Features/login/Persentation/login_screen.dart';

class LoginRoute {
  static void push(
    BuildContext context, {
    bool fromSplash = false,
  }) =>
      context.goNamed(
        NameRoutes.login,
        extra: fromSplash
            ? <String, dynamic>{
                PageTransitionAnimations.splashWoodKey: true,
              }
            : null,
      );

  static GoRoute get route => GoRoute(
        name: NameRoutes.login,
        path: NameRoutes.login.ensureWithSlash(),
        pageBuilder: (context, state) {
          const child = LoginScreen();
          if (PageTransitionAnimations.isSplashWoodExtra(state.extra)) {
            return PageTransitionAnimations.woodReveal(
              state: state,
              child: child,
            );
          }
          return const NoTransitionPage(child: child);
        },
      );
}
