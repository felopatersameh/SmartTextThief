import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Features/login/Persentation/login_screen.dart';

class LoginRoute {
  static void push(BuildContext context) =>
      context.goNamed(NameRoutes.login);

  static GoRoute get route => GoRoute(
        name: NameRoutes.login,
        path: NameRoutes.login.ensureWithSlash(),
        builder: (context, state) => const LoginScreen(),
      );
}
