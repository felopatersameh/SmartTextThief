import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Config/animations/page_transition_animations.dart';
import 'package:smart_text_thief/Config/Routes/DataScreens/dashboard_route_data.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/Pages/dashboard_screen.dart';

class DashboardRoute {
  static void push(BuildContext context, {required DashboardRouteData data}) =>
      context.pushNamed(NameRoutes.dashboard, extra: data);

  static GoRoute get route => GoRoute(
        name: NameRoutes.dashboard,
        path: NameRoutes.dashboard,
        pageBuilder: (context, state) {
          final data = state.extra;
          final routeData = data is DashboardRouteData
              ? data
              : DashboardRouteData(subjectId: data as String?);
          return PageTransitionAnimations.smooth(
            state: state,
            child: DashboardScreen(subjectId: routeData.subjectId),
          );
        },
      );
}
