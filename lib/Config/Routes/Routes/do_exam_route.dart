import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Config/Routes/DataScreens/do_exam_route_data.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Features/Exams/shared/Models/exam_model.dart';
import 'package:smart_text_thief/Features/Exams/Presentation/Do/do_exam.dart';

class DoExamRoute {
  static Future<T?> push<T>(
    BuildContext context, {
    required DoExamRouteData data,
    required String idSubject,
  }) =>
      context.pushNamed<T>(
        NameRoutes.doExam,
        pathParameters: {
          AppConstants.routeKeyId: idSubject,
          AppConstants.routeKeyExam: data.exam.id,
        },
        extra: data,
      );

  static GoRoute get route => GoRoute(
        name: NameRoutes.doExam,
        path: '${NameRoutes.doExam.removeSlash()}/:${AppConstants.routeKeyExam}',
        pageBuilder: (context, state) {
          final data = state.extra;
          final examModel =
              data is DoExamRouteData ? data.exam : data as ExamModel;
          final subjectId =
              (state.pathParameters[AppConstants.routeKeyId] ?? '').toString();
          return NoTransitionPage(
            child: DoExam(
              model: examModel,
              idSubject: subjectId,
            ),
          );
        },
      );
}

