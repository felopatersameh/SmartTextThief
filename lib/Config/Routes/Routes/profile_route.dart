import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Features/Profile/Persentation/Pages/profile_screen.dart';
import 'package:smart_text_thief/Config/Routes/Routes/about_route.dart';
import 'package:smart_text_thief/Config/Routes/Routes/help_route.dart';

class ProfileRoute {
  static void push(BuildContext context, {required String email}) =>
      context.goNamed(
        NameRoutes.profile,
        pathParameters: {
          AppConstants.routeKeyEmail: email.split('@').first,
        },
      );

  static GoRoute get route => GoRoute(
        name: NameRoutes.profile,
        path: "${NameRoutes.profile.ensureWithSlash()}/:email",
        pageBuilder: (context, state) =>
            NoTransitionPage(child: const ProfileScreen()),
        routes: [
          HelpRoute.route,
          AboutRoute.route,
        ],
      );
}
