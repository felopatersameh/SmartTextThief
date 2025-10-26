import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Core/Resources/resources.dart';
import 'cubit/main_cubit.dart';

class MainScreen extends StatelessWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainCubit(),
      child: BlocBuilder<MainCubit, MainState>(
        builder: (context, state) {
          final read = context.read<MainCubit>();
          return Scaffold(
            body: SafeArea(child: child),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white54)),
              ),
              child: BottomNavigationBar(
                showSelectedLabels: false,
                showUnselectedLabels: false,
                items: read.items,
                currentIndex: state.index,
                onTap: (value) => read.changeIndex(value,context),
                backgroundColor: AppColors.colorsBackGround,
                selectedItemColor: AppColors.colorPrimary,
                unselectedItemColor: AppColors.colorUnSelected,
              ),
            ),
          );
        },
      ),
    );
  }
}
