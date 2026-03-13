import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Config/Routes/DataScreens/subject_details_route_data.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_model.dart';
import 'package:smart_text_thief/Config/animations/page_transition_animations.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/Pages/details_screen.dart';
import 'package:smart_text_thief/Config/Routes/Routes/create_exam_route.dart';
import 'package:smart_text_thief/Config/Routes/Routes/do_exam_route.dart';
import 'package:smart_text_thief/Config/Routes/Routes/result_route.dart';

class SubjectDetailsRoute {
  static void push(
    BuildContext context, {
    required SubjectDetailsRouteData data,
  }) =>
      context.pushNamed(
        NameRoutes.subjectDetails,
        pathParameters: {
          AppConstants.routeKeyId: data.subject.subjectId,
        },
        extra: data,
      );

  static GoRoute get route => GoRoute(
        name: NameRoutes.subjectDetails,
        path:
            '${NameRoutes.subjectDetails.removeSlash()}/:${AppConstants.routeKeyId}',
        pageBuilder: (context, state) {
          final data = state.extra;
          final subjectModel = data is SubjectDetailsRouteData
              ? data.subject
              : data as SubjectModel;
          return PageTransitionAnimations.smooth(
            state: state,
            child: DetailsScreen(subjectModel: subjectModel),
          );
        },
        routes: [
          CreateExamRoute.route,
          DoExamRoute.route,
          ResultRoute.studentRoute,
          ResultRoute.teacherRoute,
        ],
      );
}
