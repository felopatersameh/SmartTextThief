import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Features/Profile/Persentation/Pages/help_screen.dart';

class HelpRoute {
  static void push(BuildContext context, {required String email}) =>
      context.pushNamed(
        NameRoutes.help,
        pathParameters: {
          AppConstants.routeKeyEmail: email.split('@').first,
        },
      );

  static GoRoute get route => GoRoute(
        name: NameRoutes.help,
        path: NameRoutes.help.removeSlash(),
        pageBuilder: (context, state) =>
            NoTransitionPage(child: HelpScreen()),
      );
}
