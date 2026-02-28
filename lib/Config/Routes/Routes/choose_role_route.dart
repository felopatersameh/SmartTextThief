import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Features/login/Persentation/choose_role_screen.dart';

class ChooseRoleRoute {
  static void push(BuildContext context) =>
      context.goNamed(NameRoutes.chooseRole);

  static GoRoute get route => GoRoute(
        name: NameRoutes.chooseRole,
        path: NameRoutes.chooseRole.ensureWithSlash(),
        builder: (context, state) => const ChooseRoleScreen(),
      );
}
