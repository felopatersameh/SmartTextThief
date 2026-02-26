import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Core/Services/Notifications/notification_model.dart';

import 'Config/di/service_locator.dart';
import 'Config/setting.dart';
import 'Core/Services/Api/api_service.dart';
import 'Core/Services/Notifications/flutter_local_notifications.dart';
import 'Core/Services/Notifications/notification_services.dart';
import 'Core/LocalStorage/local_storage_service.dart';
import 'Features/Notifications/Presentation/cubit/notifications_cubit.dart';
import 'Features/Profile/Persentation/cubit/profile_cubit.dart';
import 'Features/Subjects/Persentation/cubit/subjects_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    setupDependencies(),
    dotenv.load(fileName: '.env'),
  ]);
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    LocalStorageService.init(),
  ]);
  await Future.wait([NotificationServices.initFCM(), DioHelper.init()]);
  FirebaseMessaging.onBackgroundMessage(handlerOnBackgroundMessage);
  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> handlerOnBackgroundMessage(RemoteMessage onData) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
  final NotificationModel message = NotificationModel.fromJson(onData.data);
  await LocalNotificationService.showNotification(
    title: message.type,
    body: message.body,
    payload: jsonEncode(message.toJson()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AppScreenOrientationHelper.lockPortrait();
      NotificationServices.setOnNotificationTapCallback((message) async {
        await getIt<NotificationsCubit>().openNotification(message.id);
        await getIt<NotificationsCubit>().markNotificationRead(message.id);
        if (!mounted || message.topicId.isEmpty) return;
        AppRouter.goNamedByPath(context, NameRoutes.notification);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      enableScaleWH: () => false,
      enableScaleText: () => true,
      builder: (_, child) {
        ScreenUtil.init(context);
        return MultiBlocProvider(
          providers: [
            BlocProvider<SettingsCubit>.value(value: getIt<SettingsCubit>()),
            BlocProvider<ProfileCubit>.value(value: getIt<ProfileCubit>()),
            BlocProvider<SubjectCubit>.value(value: getIt<SubjectCubit>()),
            BlocProvider<NotificationsCubit>.value(
              value: getIt<NotificationsCubit>(),
            ),
          ],
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: AppConfig.appName,
                locale: state.locale,
                themeMode: state.themeMode,
                theme: lightThemes(),
                darkTheme: darkThemes(),
                routerConfig: AppRouter.router,
              );
            },
          ),
        );
      },
    );
  }
}
