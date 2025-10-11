import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Features/Mian/main_screen.dart';
import 'error_screen.dart';
import 'name_routes.dart';

import '../../Features/Splash/splash_screen.dart';
import '../../Features/login/login_screen.dart';

class AppRouter {
  static void nextScreenNoPath(BuildContext context, String route) =>
      context.push(route);

  static void nextScreenAndClear(BuildContext context, String route) =>
      context.go(route);

  static void backScreen(BuildContext context) =>
      context.canPop() ? context.pop() : null;

  static void goNamedByPath(BuildContext context, String name) =>
      context.goNamed(name);

  static void replaceScreen(BuildContext context, String route) =>
      context.pushReplacement(route);

  static GoRouter router = GoRouter(
    initialLocation: NameRoutes.splash,
    routes: [
      GoRoute(
        name: NameRoutes.splash,
        path: NameRoutes.splash.ensureWithSlash(),
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: NameRoutes.login,
        path: NameRoutes.login.ensureWithSlash(),
        builder: (context, state) => const LoginScreen(),
      ),
        GoRoute(
        name: NameRoutes.main,
        path: NameRoutes.main.ensureWithSlash(),
        builder: (context, state) => const MainScreen(),
      ),
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
    // redirect: (context, state) {
    //   final routes = RouteNames.staticRoutes;
    //   final myRoutes = routes.any((routes) => routes == state.fullPath);
    //   if (state.matchedLocation == NameRoutes.splash || !myRoutes) {
    //     return AppRoutes.getInitialRoute();
    //   }
    //   return null;
    // },
  );
}
