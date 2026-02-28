import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/Pages/subject_page.dart';
import 'package:smart_text_thief/Config/Routes/Routes/dashboard_route.dart';
import 'package:smart_text_thief/Config/Routes/Routes/subject_details_route.dart';

class SubjectRoute {
  static void push(BuildContext context) =>
      context.goNamed(NameRoutes.subject);

  static GoRoute get route => GoRoute(
        name: NameRoutes.subject,
        path: NameRoutes.subject.ensureWithSlash(),
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SubjectPage()),
        routes: [
          DashboardRoute.route,
          SubjectDetailsRoute.route,
        ],
      );
}
