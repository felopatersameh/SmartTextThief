import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Core/Utils/Models/user_model.dart';
import '../../Core/LocalStorage/local_storage_keys.dart';
import '../../Core/LocalStorage/local_storage_service.dart';
import '../../Config/Routes/app_router.dart';

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
        _navigateSafely(AppRouter.pushToLogin);
        return;
      }
      if (role == UserType.non.value) {
        _navigateSafely(AppRouter.pushToChooseRole);
        return;
      }
      _updateProgress(0.3);

      if (!mounted) return;
      final user = await context.read<ProfileCubit>().init();

      if (user == UserModel.empty()) {
        _navigateSafely(AppRouter.pushToLogin);
        return;
      }

      await _smoothProgressUpdate(0.4, .7, 5);

      if (!mounted) return;

      await Future.wait([
        context.read<SubjectCubit>().init(),
        // context.read<NotificationsCubit>().init(user.subscribedTopics),
      ]);

      await _smoothProgressUpdate(0.7, 1.0, 2);

      _navigateSafely(AppRouter.pushToMainScreen);
    } catch (e) {
      _navigateSafely(AppRouter.pushToLogin);
    }
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
