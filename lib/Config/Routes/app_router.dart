import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../Features/Exams/create_exam/presentation/pages/create_exam_screen.dart';
import '../../Features/Profile/Persentation/Pages/about_screen.dart';
import '../../Features/Profile/Persentation/Pages/help_screen.dart';

import '../../Core/Utils/Models/exam_exam_result.dart';
import '../../Core/Utils/Models/exam_model.dart';
import '../../Core/Utils/Models/subject_model.dart';
import '../../Features/Exams/do_exam/presentation/pages/do_exam.dart';
import '../../Features/Exams/view_exam/presentation/pages/view_exam.dart';
import '../../Features/Main/main_screen.dart';
import '../../Features/Notifications/Persentation/notification_page.dart';
import '../../Features/Profile/Persentation/Pages/profile_screen.dart';
import '../../Features/Splash/splash_screen.dart';
import '../../Features/Subjects/Persentation/Pages/subject_page.dart';
import '../../Features/Subjects/Persentation/Pages/dashboard_screen.dart';
import '../../Features/Subjects/Persentation/Pages/details_screen.dart';
import '../../Features/login/Persentation/choose_role_screen.dart';
import '../../Features/login/Persentation/login_screen.dart';
import '../Setting/settings_cubit.dart';
import 'error_screen.dart';
import 'name_routes.dart';
import 'no_connection_screen.dart';

class AppRouter {
  static void nextScreenNoPath(
    BuildContext context,
    String route, {
    Object? extra,
    Map<String, String> pathParameters = const <String, String>{},
  }) =>
      context.pushNamed(route, extra: extra, pathParameters: pathParameters);

  static void nextScreenAndClear(BuildContext context, String route) =>
      context.go(route);

  static void backScreen(BuildContext context) =>
      context.canPop() ? context.pop() : null;
  static void goNamedByPath(
    BuildContext context,
    String name, {
    Object? extra,
    Map<String, String> pathParameters = const <String, String>{},
  }) =>
      context.goNamed(name, extra: extra, pathParameters: pathParameters);

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
      GoRoute(
        name: NameRoutes.chooseRole,
        path: NameRoutes.chooseRole.ensureWithSlash(),
        builder: (context, state) => const ChooseRoleScreen(),
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
            routes: [
              GoRoute(
                name: NameRoutes.help,
                path: NameRoutes.help.ensureWithSlash(),
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: HelpScreen());
                },
              ),
              GoRoute(
                name: NameRoutes.about,
                path: NameRoutes.about.ensureWithSlash(),
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: AboutScreen());
                },
              ),
            ],
          ),
          GoRoute(
            name: NameRoutes.subject,
            path: NameRoutes.subject.ensureWithSlash(),
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const SubjectPage()),
            routes: [
              GoRoute(
                name: NameRoutes.dashboard,
                path: NameRoutes.dashboard,
                pageBuilder: (context, state) {
                  final data = state.extra as Map<String, dynamic>?;
                  return NoTransitionPage(
                    child: DashboardScreen(
                      subject: data?['subject'] as SubjectModel?,
                      exams: (data?['exams'] as List<dynamic>? ?? const [])
                          .whereType<ExamModel>()
                          .toList(),
                      results: (data?['results'] as List<dynamic>? ?? const [])
                          .whereType<ExamResultModel>()
                          .toList(),
                    ),
                  );
                },
              ),
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
                          final data = state.extra as Map;
                          final exam = data['exam'] as ExamModel;
                          final isEditMode = data['isEditMode'] as bool;
                          final nameSubject = data['nameSubject'] as String;
                          return NoTransitionPage(
                            child: ViewExam(
                              examModel: exam,
                              isEditMode: isEditMode,
                              nameSubject: nameSubject,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    name: NameRoutes.doExam,
                    path: '${NameRoutes.doExam.ensureWithSlash()}:exam',
                    pageBuilder: (context, state) {
                      final examModel = state.extra as ExamModel;
                      return NoTransitionPage(child: DoExam(model: examModel));
                    },
                  ),
                  GoRoute(
                    name: NameRoutes.result,
                    path: "/:exam${NameRoutes.result.ensureWithSlash()}/:email",
                    pageBuilder: (context, state) {
                      final data = state.extra as Map;
                      final exam = data['exam'] as ExamModel;
                      final isEditMode = data['isEditMode'] as bool;
                      final nameSubject = data['nameSubject'] as String;
                      return NoTransitionPage(
                        child: ViewExam(
                          examModel: exam,
                          isEditMode: isEditMode,
                          nameSubject: nameSubject,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            name: NameRoutes.notification,
            path: NameRoutes.notification.ensureWithSlash(),
            pageBuilder: (context, state) =>
                NoTransitionPage(child: NotificationPage()),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      if (state.error?.message.toString().contains("NoConnectionScreen") ==
          true) {
        return const NoConnectionScreen();
      }
      return const ErrorScreen();
    },
    redirect: (context, state) {
      final internet = context.read<SettingsCubit>().getConnectivity();
      // log("location::${state.matchedLocation.toString()}");
      if (!internet) throw "NoConnectionScreen";
      return null;
    },
  );
}
