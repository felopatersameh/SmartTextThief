import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../Core/Storage/Local/get_local_storage.dart';
import '../../../Config/Routes/app_router.dart';
import '../../../Config/Routes/name_routes.dart';
import '../../../Core/Resources/app_icons.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainState(index: 0));
  List<String> nameScreens = ["Subject", "Notifications", "Profile"];
  // List<Widget> screens = [Container(), SubjectPage(), ProfileScreen()];

  List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(icon: Icon(AppIcons.subject), label: "Subject"),
    BottomNavigationBarItem(
      icon: Icon(AppIcons.notificationPage),
      label: "Notifications",
    ),
    BottomNavigationBarItem(icon: Icon(AppIcons.profile), label: "Profile"),
  ];
  List<String> nav = [
    NameRoutes.subject,
    NameRoutes.notification,
    NameRoutes.profile,
  ];
  void changeIndex(int index, BuildContext context) async {
    AppRouter.nextScreenNoPath(
      context,
      nav[index],
      pathParameters: index == 2
          ? {"email": GetLocalStorage.getEmailUser().split("@").first}
          : {},
    );
    emit(state.copyWith(index: index));
  }
}
