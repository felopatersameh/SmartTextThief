import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Config/animations/page_transition_animations.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Config/Routes/Routes/choose_role_route.dart';
import 'package:smart_text_thief/Config/Routes/Routes/login_route.dart';
import 'package:smart_text_thief/Config/Routes/Routes/notification_route.dart';
import 'package:smart_text_thief/Config/Routes/Routes/profile_route.dart';
import 'package:smart_text_thief/Config/Routes/Routes/splash_route.dart';
import 'package:smart_text_thief/Config/Routes/Routes/subject_route.dart';
import 'package:smart_text_thief/Config/Setting/settings_cubit.dart';
import 'package:smart_text_thief/Features/Main/main_screen.dart';

import 'BuilderErrorsScreens/error_screen.dart';
import 'BuilderErrorsScreens/no_connection_screen.dart';

class AppRouter {
  static void backScreen(BuildContext context) =>
      context.canPop() ? context.pop() : null;

  static void pushToMainScreen(
    BuildContext context, {
    bool fromSplash = false,
  }) =>
      context.goNamed(
        NameRoutes.subject,
        extra:
            fromSplash ? {PageTransitionAnimations.splashWoodKey: true} : null,
      );

  static GoRouter router = GoRouter(
    initialLocation: NameRoutes.splash,
    routes: [
      SplashRoute.route,
      LoginRoute.route,
      ChooseRoleRoute.route,
      ShellRoute(
        pageBuilder: (context, state, child) =>
            NoTransitionPage(child: MainScreen(child: child)),
        routes: [
          ProfileRoute.route,
          SubjectRoute.route,
          NotificationRoute.route,
        ],
      ),
    ],
    errorBuilder: (context, state) {
      if (state.error?.message.toString().contains("NoConnectionScreen") ==
          true) {
        return const NoConnectionScreen();
      }
      return const ErrorScreen();
    },
    redirect: (context, state) {
      final internet = context.read<SettingsCubit>().getConnectivity();
      if (!internet) throw "NoConnectionScreen";
      return null;
    },
  );
}
