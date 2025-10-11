import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Features/Mian/cubit/main_cubit.dart';
import 'package:smart_text_thief/Features/Profile/cubit/profile_cubit.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create:(context) => MainCubit(),),
        BlocProvider(create:(context) => ProfileCubit()..init(),)
      ],
      child: BlocBuilder<MainCubit, MainState>(
        builder: (context, state) {
          final read = context.read<MainCubit>();
          return Scaffold(
            appBar: AppBar(title: Text(read.nameScreens[state.index])),
            body: SafeArea(child: read.screens[state.index]),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white54)),
              ),
              child: BottomNavigationBar(
                showSelectedLabels: false,
                showUnselectedLabels: false,
                items: read.items,
                currentIndex: state.index,
                onTap: (value) => read.changeIndex(value),
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
