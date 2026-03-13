import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Config/animations/page_transition_animations.dart';
import 'package:smart_text_thief/Config/Routes/DataScreens/view_exam_route_data.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Features/Exams/Presentation/View/preview_exam_screen.dart';

class ViewExamRoute {
  static void push(
    BuildContext context, {
    required String idSubject,
    required ViewExamRouteData data,
  }) =>
      context.pushNamed(
        NameRoutes.view,
        pathParameters: {
          AppConstants.routeKeyId: idSubject,
          AppConstants.routeKeyExam: data.exam.id,
        },
        extra: data,
      );

  static GoRoute get route => GoRoute(
        name: NameRoutes.view,
        path: ':${AppConstants.routeKeyExam}/${NameRoutes.view.removeSlash()}',
        pageBuilder: (context, state) {
          final data = state.extra;
          final routeData = data as ViewExamRouteData;
          return PageTransitionAnimations.smooth(
            state: state,
            child: PreviewExamScreen(
              examModel: routeData.exam,
              nameSubject: routeData.nameSubject,
              idSubject: routeData.idSubject,
            ),
          );
        },
      );
}
