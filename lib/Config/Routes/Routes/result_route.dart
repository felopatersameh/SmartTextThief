import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Config/animations/page_transition_animations.dart';
import 'package:smart_text_thief/Config/Routes/DataScreens/view_exam_route_data.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Features/Exams/Presentation/View/student_result_screen.dart';
import 'package:smart_text_thief/Features/Exams/Presentation/View/teacher_result_screen.dart';

class ResultRoute {
  static void pushStudent(
    BuildContext context, {
    required ViewExamRouteData data,
    required String email,
    required String idSubject,
  }) =>
      context.pushNamed(
        NameRoutes.resultStudent,
        pathParameters: {
          AppConstants.routeKeyId: idSubject,
          AppConstants.routeKeyExam: data.exam.id,
          AppConstants.routeKeyEmail: email.split('@').first,
        },
        extra: data,
      );

  static void pushTeacher(
    BuildContext context, {
    required ViewExamRouteData data,
    required String email,
    required String idSubject,
  }) =>
      context.pushNamed(
        NameRoutes.resultTeacher,
        pathParameters: {
          AppConstants.routeKeyId: idSubject,
          AppConstants.routeKeyExam: data.exam.id,
          AppConstants.routeKeyEmail: email.split('@').first,
        },
        extra: data,
      );

  static GoRoute get studentRoute => GoRoute(
        name: NameRoutes.resultStudent,
        path:
            ':${AppConstants.routeKeyExam}/${NameRoutes.resultStudent.removeSlash()}/:${AppConstants.routeKeyEmail}',
        pageBuilder: (context, state) {
          final data = state.extra;
          final routeData = data as ViewExamRouteData;
          return PageTransitionAnimations.smooth(
            state: state,
            child: StudentResultScreen(
              examModel: routeData.exam,
              idSubject: routeData.idSubject,
            ),
          );
        },
      );

  static GoRoute get teacherRoute => GoRoute(
        name: NameRoutes.resultTeacher,
        path:
            ':${AppConstants.routeKeyExam}/${NameRoutes.resultTeacher.removeSlash()}/:${AppConstants.routeKeyEmail}',
        pageBuilder: (context, state) {
          final data = state.extra;
          final routeData = data as ViewExamRouteData;
          return PageTransitionAnimations.smooth(
            state: state,
            child: TeacherResultScreen(
              examModel: routeData.exam,
              nameSubject: routeData.nameSubject,
              idSubject: routeData.idSubject,
            ),
          );
        },
      );
}
