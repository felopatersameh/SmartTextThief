import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../Core/Resources/app_icons.dart';
import '../../Subjects/View/Pages/subject_page.dart';
import '../../Profile/profile_screen.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainState(index: 1));
  List<String> nameScreens = ["Home", "Exams", "Profile"];
  List<Widget> screens = [Container(), SubjectPage(), ProfileScreen()];

  List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(icon: Icon(AppIcons.homepage), label: "Home"),
    BottomNavigationBarItem(icon: Icon(AppIcons.exame), label: "Exams"),
    BottomNavigationBarItem(icon: Icon(AppIcons.profile), label: "Profile"),
  ];

  void changeIndex(int index) => emit(state.copyWith(index: index));
}
