import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Notifications/Persentation/cubit/notifications_cubit.dart';
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
      _updateProgress(0.1);

      final bool isLoggedIn = LocalStorageService.getValue(
        LocalStorageKeys.isLoggedIn,
        defaultValue: false,
      );
      final String id = LocalStorageService.getValue(
        LocalStorageKeys.id,
        defaultValue: "",
      );
      _updateProgress(0.2);

      if (id.isEmpty || !isLoggedIn) {
        _navigateSafely(AppRouter.pushToLogin);
        return;
      }

      _updateProgress(0.3);

      if (!mounted) return;
      final user = await context.read<ProfileCubit>().init();
      if (user.userId == "-#") {
        _navigateSafely(AppRouter.pushToLogin);
        return;
      }
      if (user.userType == UserType.non) {
        _navigateSafely(AppRouter.pushToChooseRole);
        return;
      }
      await _smoothProgressUpdate(0.4, .7, 5);

      if (!mounted) return;

      await Future.wait([
        context.read<SubjectCubit>().init(user.userEmail, user.isStu),
        context.read<NotificationsCubit>().init(user.subscribedTopics),
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

  void _updateProgress(double value) {
    if (mounted) _controller.value = value;
  }

  Future<void> _smoothProgressUpdate(
      double start, double end, int steps) async {
    final double stepSize = (end - start) / steps;

    for (int i = 1; i <= steps; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      _updateProgress(start + (stepSize * i));
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
