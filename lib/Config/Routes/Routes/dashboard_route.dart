import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Config/Routes/DataScreens/dashboard_route_data.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/Pages/dashboard_screen.dart';

class DashboardRoute {
  static void push(BuildContext context, {required DashboardRouteData data}) =>
      context.pushNamed(NameRoutes.dashboard, extra: data);

  static GoRoute get route => GoRoute(
        name: NameRoutes.dashboard,
        path: NameRoutes.dashboard,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: DashboardScreen()),
      );
}
