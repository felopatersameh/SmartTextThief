import 'package:flutter/material.dart';
import '../../Config/Routes/app_router.dart';
import '../../Config/Routes/name_routes.dart';

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
      duration: const Duration(seconds: 5),
    );
    _navigateToMainScreen();
  }

  Future<void> _navigateToMainScreen() async {
    _controller.value = 0.1;
    await Future.delayed(const Duration(milliseconds: 300));
    _controller.value = 0.2;

    await Future.delayed(const Duration(milliseconds: 300));
    _controller.value = 0.3;

    await Future.delayed(const Duration(milliseconds: 300));
    _controller.value = 0.4;

    await Future.delayed(const Duration(milliseconds: 300));
    _controller.value = 0.5;

    await Future.delayed(const Duration(milliseconds: 300));
    _controller.value = 0.6;

    await Future.delayed(const Duration(milliseconds: 300));
    _controller.value = 0.9;

    await Future.delayed(const Duration(milliseconds: 300));
    _controller.value = 1.0;

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      AppRouter.goNamedByPath(context, NameRoutes.login);
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
