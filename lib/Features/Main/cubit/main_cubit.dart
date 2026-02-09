import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Core/LocalStorage/get_local_storage.dart';
import '../../../Config/Routes/app_router.dart';
import '../../../Core/Resources/resources.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:badges/badges.dart' as badges;

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainState(index: 0));
  List<String> nameScreens = [
    MainStrings.subjectTab,
    MainStrings.notificationsTab,
    MainStrings.profileTab,
  ];
  // List<Widget> screens = [Container(), SubjectPage(), ProfileScreen()];

    
List<BottomNavigationBarItem> items(int notificationsBadgeCount) {
  return [
    BottomNavigationBarItem(
      icon: Icon(AppIcons.subject),
      label: MainStrings.subjectTab,
    ),
    BottomNavigationBarItem(
      icon: bottomNavIconWithBadge(
        notificationsBadgeCount,
        icon: Icon(AppIcons.notificationPage),
      ),
      label: MainStrings.notificationsTab,
    ),
    BottomNavigationBarItem(
      icon: Icon(AppIcons.profile),
      label: MainStrings.profileTab,
    ),
  ];
}

  void changeIndex(int index, BuildContext context) async {
    if (index == 0) {
      AppRouter.pushToMainScreen(context);
    } else if (index == 1) {
      AppRouter.pushToNotifications(context);
    } else {
      AppRouter.pushToProfile(
        context,
        email: GetLocalStorage.getEmailUser(),
      );
    }
    emit(state.copyWith(index: index));
  }

  @override
  Future<void> close() {
    emit(MainState(index: 0));
    return super.close();
  }
}

Widget bottomNavIconWithBadge(
  int newUsersCount, {
  IconData? iconData,
  Icon? icon,
}) {
  return badges.Badge(
    position: badges.BadgePosition.topEnd(top: -2, end: -4),
    badgeContent: Text(
      '$newUsersCount',
      style: TextStyle(color: AppColors.textWhite, fontSize: 12.sp),
    ),
    showBadge: newUsersCount > 0,
    child: icon ?? Icon(iconData, size: 30.sp),
  );
}
