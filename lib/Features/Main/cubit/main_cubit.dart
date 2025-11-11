import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Features/Notifications/cubit/notifications_cubit.dart';
import '../../../Core/Storage/Local/get_local_storage.dart';
import '../../../Config/Routes/app_router.dart';
import '../../../Config/Routes/name_routes.dart';
import '../../../Core/Resources/app_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:badges/badges.dart' as badges;

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainState(index: 0));
  List<String> nameScreens = ["Subject", "Notifications", "Profile"];
  // List<Widget> screens = [Container(), SubjectPage(), ProfileScreen()];

  List<BottomNavigationBarItem> items(BuildContext context) {
    int notificationsBadgeCount = context
        .read<NotificationsCubit>()
        .state
        .badgeCount;
    return [
      BottomNavigationBarItem(icon: Icon(AppIcons.subject), label: "Subject"),
      BottomNavigationBarItem(
        icon: bottomNavIconWithBadge(
          notificationsBadgeCount,
          icon: Icon(AppIcons.notificationPage),
        ),
        label: "Notifications",
      ),
      BottomNavigationBarItem(icon: Icon(AppIcons.profile), label: "Profile"),
    ];
  }

  List<String> nav = [
    NameRoutes.subject,
    NameRoutes.notification,
    NameRoutes.profile,
  ];
  void changeIndex(int index, BuildContext context) async {
    AppRouter.goNamedByPath(
      context,
      nav[index],
      pathParameters: index == 2
          ? {"email": GetLocalStorage.getEmailUser().split("@").first}
          : {},
    );
    emit(state.copyWith(index: index));
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
      style: TextStyle(color: Colors.white, fontSize: 12.sp),
    ),
    showBadge: newUsersCount > 0,
    child: icon ?? Icon(iconData, size: 30.sp),
  );
}
