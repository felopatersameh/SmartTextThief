import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import '../../Features/Exams/create_exam/presentation/pages/create_exam_screen.dart';
import '../../Features/Profile/Persentation/Pages/about_screen.dart';
import '../../Features/Profile/Persentation/Pages/help_screen.dart';

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
import 'route_data.dart';

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

  static String _emailPathValue(String email) => email.split('@').first;

  static void pushToLogin(BuildContext context) {
    goNamedByPath(context, NameRoutes.login);
  }

  static void pushToChooseRole(BuildContext context) {
    goNamedByPath(context, NameRoutes.chooseRole);
  }

  static void pushToMainScreen(BuildContext context) {
    goNamedByPath(context, NameRoutes.subject);
  }

  static void pushToNotifications(BuildContext context) {
    goNamedByPath(context, NameRoutes.notification);
  }

  static void pushToProfile(
    BuildContext context, {
    required String email,
  }) {
    goNamedByPath(
      context,
      NameRoutes.profile,
      pathParameters: {
        AppConstants.routeKeyEmail: _emailPathValue(email),
      },
    );
  }

  static void pushToHelp(
    BuildContext context, {
    required String email,
  }) {
    nextScreenNoPath(
      context,
      NameRoutes.help,
      pathParameters: {
        AppConstants.routeKeyEmail: _emailPathValue(email),
      },
    );
  }

  static void pushToAbout(
    BuildContext context, {
    required String email,
  }) {
    nextScreenNoPath(
      context,
      NameRoutes.about,
      pathParameters: {
        AppConstants.routeKeyEmail: _emailPathValue(email),
      },
    );
  }

  static void pushToSubjectDetails(
    BuildContext context, {
    required SubjectDetailsRouteData data,
  }) {
    nextScreenNoPath(
      context,
      NameRoutes.subjectDetails,
      pathParameters: {
        AppConstants.routeKeyId: data.subject.subjectId,
      },
      extra: data,
    );
  }

  static void pushToCreateExam(
    BuildContext context, {
    required CreateExamRouteData data,
  }) {
    nextScreenNoPath(
      context,
      NameRoutes.createExam,
      pathParameters: {
        AppConstants.routeKeyId: data.subject.subjectId,
      },
      extra: data,
    );
  }

  static void pushToViewExam(
    BuildContext context, {
    required ViewExamRouteData data,
  }) {
    nextScreenNoPath(
      context,
      NameRoutes.view,
      pathParameters: {
        AppConstants.routeKeyId: data.exam.examIdSubject,
        AppConstants.routeKeyExam: data.exam.examId,
      },
      extra: data,
    );
  }

  static void pushToResult(
    BuildContext context, {
    required ViewExamRouteData data,
    required String email,
  }) {
    nextScreenNoPath(
      context,
      NameRoutes.result,
      pathParameters: {
        AppConstants.routeKeyId: data.exam.examIdSubject,
        AppConstants.routeKeyExam: data.exam.examId,
        AppConstants.routeKeyEmail: _emailPathValue(email),
      },
      extra: data,
    );
  }

  static void pushToDoExam(
    BuildContext context, {
    required DoExamRouteData data,
  }) {
    nextScreenNoPath(
      context,
      NameRoutes.doExam,
      pathParameters: {
        AppConstants.routeKeyId: data.exam.examIdSubject,
        AppConstants.routeKeyExam: data.exam.examId,
      },
      extra: data,
    );
  }

  static void pushToDashboard(
    BuildContext context, {
    required DashboardRouteData data,
  }) {
    nextScreenNoPath(
      context,
      NameRoutes.dashboard,
      extra: data,
    );
  }

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
                  final data = state.extra;
                  final dashboardData = data is DashboardRouteData
                      ? data
                      : const DashboardRouteData();
                  return NoTransitionPage(
                    child: DashboardScreen(
                      subject: dashboardData.subject,
                      exams: dashboardData.exams,
                      results: dashboardData.results,
                    ),
                  );
                },
              ),
              GoRoute(
                name: NameRoutes.subjectDetails,
                path: '${NameRoutes.subjectDetails.ensureWithSlash()}:id',
                pageBuilder: (context, state) {
                  final data = state.extra;
                  final subjectModel = data is SubjectDetailsRouteData
                      ? data.subject
                      : data as SubjectModel;
                  return NoTransitionPage(
                    child: DetailsScreen(subjectModel: subjectModel),
                  );
                },
                routes: [
                  GoRoute(
                    name: NameRoutes.createExam,
                    path: NameRoutes.createExam.ensureWithSlash(),
                    pageBuilder: (context, state) {
                      final data = state.extra;
                      final subjectModel = data is CreateExamRouteData
                          ? data.subject
                          : data as SubjectModel;
                      return NoTransitionPage(
                        child: CreateExamScreen(subject: subjectModel),
                      );
                    },
                    routes: [
                      GoRoute(
                        name: NameRoutes.view,
                        path: "/:exam${NameRoutes.view.ensureWithSlash()}",
                        pageBuilder: (context, state) {
                          final data = state.extra;
                          final routeData = data is ViewExamRouteData
                              ? data
                              : ViewExamRouteData(
                                  exam: (data as Map)[
                                      AppConstants.routeKeyExam] as ExamModel,
                                  isEditMode:
                                      data[AppConstants.routeKeyIsEditMode]
                                          as bool,
                                  nameSubject:
                                      data[AppConstants.routeKeyNameSubject]
                                          as String,
                                );
                          return NoTransitionPage(
                            child: ViewExam(
                              examModel: routeData.exam,
                              isEditMode: routeData.isEditMode,
                              nameSubject: routeData.nameSubject,
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
                      final data = state.extra;
                      final examModel = data is DoExamRouteData
                          ? data.exam
                          : data as ExamModel;
                      return NoTransitionPage(child: DoExam(model: examModel));
                    },
                  ),
                  GoRoute(
                    name: NameRoutes.result,
                    path: "/:exam${NameRoutes.result.ensureWithSlash()}/:email",
                    pageBuilder: (context, state) {
                      final data = state.extra;
                      final routeData = data is ViewExamRouteData
                          ? data
                          : ViewExamRouteData(
                              exam: (data as Map)[
                                  AppConstants.routeKeyExam] as ExamModel,
                              isEditMode:
                                  data[AppConstants.routeKeyIsEditMode]
                                      as bool,
                              nameSubject:
                                  data[AppConstants.routeKeyNameSubject]
                                      as String,
                            );
                      return NoTransitionPage(
                        child: ViewExam(
                          examModel: routeData.exam,
                          isEditMode: routeData.isEditMode,
                          nameSubject: routeData.nameSubject,
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
