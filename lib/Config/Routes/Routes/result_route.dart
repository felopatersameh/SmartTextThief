import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Config/Routes/DataScreens/view_exam_route_data.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Features/exam/presentation/pages/view_exam.dart';

class ResultRoute {
  static void push(
    BuildContext context, {
    required ViewExamRouteData data,
    required String email,
    required String idSubject,
  }) =>
      context.pushNamed(
        NameRoutes.result,
        pathParameters: {
          AppConstants.routeKeyId: idSubject,
          AppConstants.routeKeyExam: data.exam.id,
          AppConstants.routeKeyEmail: email.split('@').first,
        },
        extra: data,
      );

  static GoRoute get route => GoRoute(
        name: NameRoutes.result,
        path:
            ':${AppConstants.routeKeyExam}/${NameRoutes.result.removeSlash()}/:${AppConstants.routeKeyEmail}',
        pageBuilder: (context, state) {
          final data = state.extra;
          final routeData = data as ViewExamRouteData;
          return NoTransitionPage(
            child: ViewExam(
              examModel: routeData.exam,
              isEditMode: routeData.isEditMode,
              nameSubject: routeData.nameSubject,
              idSubject: routeData.idSubject,
              isTeacherView: routeData.isTeacherView,
            ),
          );
        },
      );
}

