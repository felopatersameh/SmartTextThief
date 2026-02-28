import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Features/Profile/Persentation/Pages/about_screen.dart';

class AboutRoute {
  static void push(BuildContext context, {required String email}) =>
      context.pushNamed(
        NameRoutes.about,
        pathParameters: {
          AppConstants.routeKeyEmail: email.split('@').first,
        },
      );

  static GoRoute get route => GoRoute(
        name: NameRoutes.about,
        path: NameRoutes.about.removeSlash(),
        pageBuilder: (context, state) =>
            NoTransitionPage(child: AboutScreen()),
      );
}
