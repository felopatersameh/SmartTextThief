import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Features/Notifications/Presentation/notification_page.dart';

class NotificationRoute {
  static void push(BuildContext context) =>
      context.pushNamed(NameRoutes.notification);

  static GoRoute get route => GoRoute(
        name: NameRoutes.notification,
        path: NameRoutes.notification.ensureWithSlash(),
        pageBuilder: (context, state) =>
            NoTransitionPage(child: NotificationPage()),
      );
}
