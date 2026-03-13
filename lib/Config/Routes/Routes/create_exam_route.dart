import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Config/animations/page_transition_animations.dart';
import 'package:smart_text_thief/Config/Routes/DataScreens/create_exam_route_data.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_model.dart';
import 'package:smart_text_thief/Features/Exams/Presentation/Create/create_exam_screen.dart';
import 'package:smart_text_thief/Config/Routes/Routes/view_exam_route.dart';

class CreateExamRoute {
  static void push(
    BuildContext context, {
    required CreateExamRouteData data,
  }) =>
      context.pushNamed(
        NameRoutes.createExam,
        pathParameters: {
          AppConstants.routeKeyId: data.subject.subjectId,
        },
        extra: data,
      );

  static GoRoute get route => GoRoute(
        name: NameRoutes.createExam,
        path: NameRoutes.createExam.removeSlash(),
        pageBuilder: (context, state) {
          final data = state.extra;
          final subjectModel =
              data is CreateExamRouteData ? data.subject : data as SubjectModel;
          return PageTransitionAnimations.smooth(
            state: state,
            child: CreateExamScreen(subject: subjectModel),
          );
        },
        routes: [
          ViewExamRoute.route,
        ],
      );
}
