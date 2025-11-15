import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Features/Notifications/Persentation/cubit/notifications_cubit.dart';
import '../../Core/LocalStorage/local_storage_keys.dart';
import '../../Core/LocalStorage/local_storage_service.dart';
import '../../Config/Routes/app_router.dart';
import '../../Config/Routes/name_routes.dart';

import '../Subjects/Persentation/cubit/subjects_cubit.dart';
import '../Profile/Persentation/cubit/profile_cubit.dart';
import 'loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _navigateToMainScreen();
  }

  Future<void> _navigateToMainScreen() async {
    try {
      _controller.value = 0.1;

      final bool isLoggedIn = LocalStorageService.getValue(
        LocalStorageKeys.isLoggedIn,
        defaultValue: "",
      );
      final String id = LocalStorageService.getValue(
        LocalStorageKeys.id,
        defaultValue: "",
      );
      _controller.value = 0.2;

      if (id.isEmpty || !isLoggedIn) {
        if (mounted) {
          AppRouter.goNamedByPath(context, NameRoutes.login);
        }
        return;
      }
      _controller.value = 0.3;
      _controller.value = 0.4;

      if (!mounted) return;
      final  user = await context.read<ProfileCubit>().init() ;
      if (user.userId == "-#") {
        if (!mounted) return;
        AppRouter.goNamedByPath(context, NameRoutes.login);
      }
      await Future.delayed(const Duration(milliseconds: 300));
      _controller.value = 0.5;

      if (!mounted) return;
      await Future.wait([
        context.read<SubjectCubit>().init(user.userEmail, user.isStu),
        context.read<NotificationsCubit>().init(user.subscribedTopics),
      ]);
      await Future.delayed(const Duration(milliseconds: 300));
      _controller.value = 0.6;
      await Future.delayed(const Duration(milliseconds: 300));
      _controller.value = 0.7;
      await Future.delayed(const Duration(milliseconds: 300));
      _controller.value = 0.8;
      await Future.delayed(const Duration(milliseconds: 300));
      _controller.value = 0.9;
      await Future.delayed(const Duration(milliseconds: 300));
      _controller.value = 1.0;

      if (mounted) {
        AppRouter.goNamedByPath(context, NameRoutes.subject);
      }
    } catch (e) {
      if (mounted) {
        AppRouter.goNamedByPath(context, NameRoutes.login);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(child: LoadingIndicator(controller: _controller)),
      ),
    );
  }
}
