import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Core/Utils/Models/user_model.dart';
import '../../Config/Routes/Routes/choose_role_route.dart';
import '../../Config/Routes/Routes/login_route.dart';
import '../../Core/LocalStorage/local_storage_keys.dart';
import '../../Core/LocalStorage/local_storage_service.dart';
import '../../Config/Routes/app_router.dart';

import '../Notifications/Presentation/cubit/notifications_cubit.dart';
import '../Subjects/Persentation/cubit/subjects_cubit.dart';
import '../Profile/Persentation/cubit/profile_cubit.dart';
import '../../Core/Utils/Enums/enum_user.dart';
import '../login/Persentation/Widgets/sections/background_container.dart';
import 'loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _navigationStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToMainScreen();
    });
  }

  Future<void> _navigateToMainScreen() async {
    try {
      await _updateProgress(0.1);

      final bool isLoggedIn = await LocalStorageService.getValue(
        LocalStorageKeys.isLoggedIn,
        defaultValue: false,
      );
      final String token = await LocalStorageService.getValue(
        LocalStorageKeys.token,
        defaultValue: "",
      );

      final String role = await LocalStorageService.getValue(
        LocalStorageKeys.role,
        defaultValue: UserType.non.value,
      );
      await _updateProgress(0.2);

      if (token.isEmpty || !isLoggedIn) {
        await _navigateWithSplashTransition(
          (ctx) => LoginRoute.push(ctx, fromSplash: true),
        );
        return;
      }
      if (role == UserType.non.value) {
        await _navigateWithSplashTransition(
          (ctx) => ChooseRoleRoute.push(ctx, fromSplash: true),
        );
        return;
      }
      await _updateProgress(0.3);

      if (!mounted) return;
      final user = await context.read<ProfileCubit>().init();

      if (user == UserModel.empty()) {
        await _navigateWithSplashTransition(
          (ctx) => LoginRoute.push(ctx, fromSplash: true),
        );
        return;
      }

      await _smoothProgressUpdate(0.4, .7, 5);

      if (!mounted) return;

      await Future.wait([
        context.read<SubjectCubit>().init(),
        context.read<NotificationsCubit>().init(),
      ]);

      await _smoothProgressUpdate(0.7, 1.0, 2);

      await _navigateWithSplashTransition(
        (ctx) => AppRouter.pushToMainScreen(ctx, fromSplash: true),
      );
    } catch (e) {
      await _navigateWithSplashTransition(
        (ctx) => LoginRoute.push(ctx, fromSplash: true),
      );
    }
  }

  Future<void> _navigateWithSplashTransition(
    void Function(BuildContext) action,
  ) async {
    if (!mounted || _navigationStarted) return;
    _navigationStarted = true;
    await Future.delayed(const Duration(milliseconds: 60));

    _navigateSafely(action);
  }

  void _navigateSafely(void Function(BuildContext) action) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      action(context);
    });
  }

  Future<void> _updateProgress(double value) async {
    if (mounted) _controller.value = value;
  }

  Future<void> _smoothProgressUpdate(
      double start, double end, int steps) async {
    final double stepSize = (end - start) / steps;

    for (int i = 1; i <= steps; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      await _updateProgress(start + (stepSize * i));
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
      body: Stack(
        children: [
          const Positioned.fill(child: BackgroundContainer()),
          SafeArea(
            child: Center(child: LoadingIndicator(controller: _controller)),
          ),
        ],
      ),
    );
  }
}
