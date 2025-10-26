import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../Core/Storage/Local/get_local_storge.dart';
import '../../../Config/Routes/app_router.dart';
import '../../../Config/Routes/name_routes.dart';
import '../../../Core/Resources/app_icons.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainState(index: 1));
  List<String> nameScreens = ["Home", "Subject", "Profile"];
  // List<Widget> screens = [Container(), SubjectPage(), ProfileScreen()];

  List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(icon: Icon(AppIcons.homepage), label: "Home"),
    BottomNavigationBarItem(icon: Icon(AppIcons.subject), label: "Subject"),
    BottomNavigationBarItem(icon: Icon(AppIcons.profile), label: "Profile"),
  ];
  List<String> nav = [NameRoutes.home, NameRoutes.subject, NameRoutes.profile];
  void changeIndex(int index, BuildContext context) async {
    AppRouter.nextScreenNoPath(
      context,
      nav[index],
      pathParameters: index == 2
          ? {"email": GetLocalStorge.getemailUser().split("@").first}
          : {},
    );
    emit(state.copyWith(index: index));
  }
}
