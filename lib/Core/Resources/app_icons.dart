import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icon_broken/icon_broken.dart';
import 'package:icons_plus/icons_plus.dart';

import 'app_colors.dart';

class AppIcons {
  static const Icon arrowBack = Icon(IconBroken.Arrow___Left);

  static Icon splash = Icon(
    IconBroken.Scan,
    size: 50.sp,
    color: Colors.blue.shade700,
  );

  //******************************************************** for Login && SingUp
  static Icon google = Icon(
    FontAwesome.google_brand,
    size: 24.sp,
    color: Colors.white,
  );
  static Icon facebook = Icon(
    FontAwesome.facebook_brand,
    size: 24.sp,
    color: Colors.white,
  );
  static const IconData email = EvaIcons.email_outline;
  static const IconData name = IconBroken.Profile;
  static const IconData phone = IconBroken.Call;
  static const IconData password = IconBroken.Lock;
  static const IconData visibility = EvaIcons.eye_outline;
  static const IconData notVisibility = EvaIcons.eye_off_outline;

  //******************************************************** for navigate
  static const IconData homepage = IconBroken.Home;
  static const IconData profile = IconBroken.Profile;
  static const IconData studenst = EvaIcons.people;
  static const IconData exame = IconBroken.Document;

  static Widget taskPage = Container(
    clipBehavior: Clip.antiAliasWithSaveLayer,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: AppColors.colorPrimary,
    ),
    width: 40,
    height: 40,
    child: const Icon(
      BoxIcons.bx_circle,
      color: Color.fromRGBO(0, 0, 1, .5),
      size: 27,
    ),
  );
  static Widget taskPage2 = Container(
    clipBehavior: Clip.antiAliasWithSaveLayer,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),

      // color: AppColors.colorPrimary,
    ),
    width: 40,
    height: 40,
    child: Icon(
      BoxIcons.bx_circle,
      color: Color.fromRGBO(255, 237, 237, 1),
      size: 27.w,
    ),
  );
  // static const IconData add = EvaIcons.plus;
  static const IconData notificationPage = IconBroken.Notification;

  //******************************************************** for Home Page
  // static const Icon search = Icon(
  //   IconBroken.Search,
  //   color: AppColors.colorTitleTextOut,
  // );
  //******************************************************** for Chat Page
  static const IconData send = IconBroken.Send;
  static const IconData voice = IconBroken.Voice;

  //******************************************************** for Profile Page
  static const Icon arrowUnder = Icon(IconBroken.Arrow___Down_2);
  static const Icon arrowUp = Icon(IconBroken.Arrow___Up_2);
  static const Icon task = Icon(Bootstrap.list_task);
  static Icon edite = Icon(
    IconBroken.Edit_Square,
    size: 30.w,
    color: AppColors.colorIcons,
  );
  static const Icon true_ = Icon(FontAwesome.check_solid);
  static const Icon false_ = Icon(FontAwesome.xmark_solid);
  static const Icon logout = Icon(IconBroken.Logout);

  //******************************************************** for Tasks
  static const IconData date = Icons.date_range_sharp;
  static const IconData time = Icons.date_range_sharp;
  static const Icon adduser = Icon(IconBroken.User);
  static const Icon add = Icon(
    FontAwesome.plus_solid,
    color: AppColors.textWhite,
  );
  static const Icon remove = Icon(Icons.remove, color: AppColors.colorIcons);

  //******************************************************** for Subjects and Exams Cards
  static const IconData subject = IconBroken.Bookmark;
  static const IconData people = IconBroken.Profile;
  static const IconData quiz = IconBroken.Document;
  static const IconData calendar = IconBroken.Calendar;
  static const IconData arrowForward = IconBroken.Arrow___Right_2;
  static const IconData share = EvaIcons.share;
  static const IconData download = IconBroken.Download;
  static const IconData refresh = EvaIcons.refresh;
  static const IconData showQuestions = IconBroken.Show;

  //******************************************************** for Chart/Graph
  static const IconData chart = Bootstrap.bar_chart_fill;
  static const IconData code = Bootstrap.code;
  static const IconData avarege = Bootstrap.percent;
  static const IconData copy = Bootstrap.copy;
} 
