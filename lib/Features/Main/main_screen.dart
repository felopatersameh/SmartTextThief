import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../Core/Resources/resources.dart';
import '../../Config/Routes/name_routes.dart';
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

          final isExamScreen = _isExamScreen(context);

          return Scaffold(
            body: SafeArea(child: child),
            bottomNavigationBar: isExamScreen
                ? null
                : Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.white54)),
                    ),
                    child: BottomNavigationBar(
                      showSelectedLabels: false,
                      showUnselectedLabels: false,
                      items: read.items(context),
                      currentIndex: state.index,
                      onTap: (value) => read.changeIndex(value, context),
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

  bool _isExamScreen(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final examPaths = [
      NameRoutes.doExam.ensureWithSlash(),
      NameRoutes.subjectDetails.ensureWithSlash(),
      NameRoutes.createExam.ensureWithSlash(),
      NameRoutes.view.ensureWithSlash(),
    ];

    return examPaths.any((path) => location.contains(path));
  }
}
