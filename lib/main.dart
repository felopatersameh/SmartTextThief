import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'Config/setting.dart';
import 'Core/Services/Firebase/firebase_service.dart';
import 'Core/Services/Firebase/real_time_firbase.dart';
import 'Core/Services/Notifications/notification_services.dart';
import 'Core/Storage/Local/local_storage_service.dart';
import 'Features/Notifications/cubit/notifications_cubit.dart';
import 'Features/Profile/cubit/profile_cubit.dart';
import 'Features/Subjects/cubit/subjects_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    Hive.initFlutter(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);
  await LocalStorageService.init();
  await Future.wait([
    FirebaseServices.instance.initialize(),
    RealtimeFirebase.initialize(),
    NotificationServices.initFCM(),
  ]);
  FirebaseMessaging.onBackgroundMessage(handlerOnBackgroundMessage);
  runApp( const MyApp());
}

@pragma('vm:entry-point')
Future<void> handlerOnBackgroundMessage(RemoteMessage onData) async {
  // debugPrint("onMessage:: ${onData.notification?.toMap()}");
  //  final notification = onData.notification;

  //   if (notification != null) {
  //     final title = notification.title ?? 'No Title';
  //     final body = notification.body ?? 'No Body';

  //    await LocalNotificationService.showNotification(
  //       title: title,
  //       body: body,
  //     );
  //   }
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
            BlocProvider(create: (context) => SettingsCubit(), lazy: true),
            BlocProvider(create: (context) => ProfileCubit()),
            BlocProvider(create: (context) => SubjectCubit()),
            BlocProvider(create: (context) => NotificationsCubit()),
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
