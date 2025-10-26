import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_model.dart';
import 'package:smart_text_thief/Features/Exams/View/Pages/create_exam_screen.dart';
import 'package:smart_text_thief/Features/Exams/View/Pages/view_exam.dart';
import 'package:smart_text_thief/Features/Mian/main_screen.dart';
import 'package:smart_text_thief/Features/Profile/profile_screen.dart';
import 'package:smart_text_thief/Features/Subjects/View/Pages/details_screen.dart';
import 'package:smart_text_thief/Features/Subjects/View/Pages/subject_page.dart';
import 'error_screen.dart';
import 'name_routes.dart';

import '../../Features/Splash/splash_screen.dart';
import '../../Features/login/login_screen.dart';

class AppRouter {
  static void nextScreenNoPath(
    BuildContext context,
    String route, {
    Object? extra,
    Map<String, String> pathParameters = const <String, String>{},
  }) => context.pushNamed(route, extra: extra, pathParameters: pathParameters);

  static void nextScreenAndClear(BuildContext context, String route) =>
      context.go(route);

  static void backScreen(BuildContext context) =>
      context.canPop() ? context.pop() : null;
  static void goNamedByPath(
    BuildContext context,
    String name, {
    Object? extra,
    Map<String, String> pathParameters = const <String, String>{},
  }) => context.goNamed(name, extra: extra, pathParameters: pathParameters);

  static void replaceScreen(BuildContext context, String route) =>
      context.pushReplacement(route);

  static GoRouter router = GoRouter(
    initialLocation: NameRoutes.splash,

    routes: [
      GoRoute(
        name: NameRoutes.splash,
        path: NameRoutes.splash.ensureWithSlash(),
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: NameRoutes.login,
        path: NameRoutes.login.ensureWithSlash(),
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        pageBuilder: (context, state, child) =>
            NoTransitionPage(child: MainScreen(child: child)),
        routes: [
          GoRoute(
            name: NameRoutes.profile,
            path: "${NameRoutes.profile.ensureWithSlash()}/:email",
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const ProfileScreen()),
          ),
          GoRoute(
            name: NameRoutes.subject,
            path: NameRoutes.subject.ensureWithSlash(),
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const SubjectPage()),
            routes: [
              GoRoute(
                name: NameRoutes.subjectDetails,
                path: '${NameRoutes.subjectDetails.ensureWithSlash()}:id',
                pageBuilder: (context, state) {
                  final subjectModel = state.extra as SubjectModel;
                  return NoTransitionPage(
                    child: DetailsScreen(subjectModel: subjectModel),
                  );
                },
                routes: [
                  GoRoute(
                    name: NameRoutes.createExam,
                    path: NameRoutes.createExam.ensureWithSlash(),
                    pageBuilder: (context, state) {
                      final subjectModel = state.extra as SubjectModel;
                      return NoTransitionPage(
                        child: CreateExamScreen(subject: subjectModel),
                      );
                    },
                    routes: [
                      GoRoute(
                        name: NameRoutes.view,
                        path: "/:exam${NameRoutes.view.ensureWithSlash()}",
                        pageBuilder: (context, state) {
                          final exam = state.extra as ExamModel;
                          return NoTransitionPage(
                            child: ViewExam(examModel: exam),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            name: NameRoutes.home,
            path: NameRoutes.home.ensureWithSlash(),
            pageBuilder: (context, state) =>
                NoTransitionPage(child: Container()),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
    redirect: (context, state) {
      log("location::${state.matchedLocation.toString()}");
    },
  );
}
