import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Config/setting.dart';
import 'Widgets/body_screen.dart';
import 'Cubit/authentication_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthenticationCubit(),
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            physics: AppConfig.physicsCustomScrollView,
            slivers: [
              SliverFillRemaining(
                fillOverscroll: false,
                hasScrollBody: true,
                child: Center(child: BodyScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
