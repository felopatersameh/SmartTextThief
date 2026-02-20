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

  //******************************************************** for Login && SignUp
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
  static const IconData students = EvaIcons.people;
  static const IconData exam = IconBroken.Document;

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
    ),
    width: 40,
    height: 40,
    child: Icon(
      BoxIcons.bx_circle,
      color: const Color.fromRGBO(255, 237, 237, 1),
      size: 27.w,
    ),
  );
  static const IconData notificationPage = IconBroken.Notification;

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

  //******************************************************** Centralized Material Icons
  static const IconData verifiedUserOutlined = Icons.verified_user_outlined;
  static const IconData search = Icons.search;
  static const IconData searchOff = Icons.search_off;
  static const IconData lockOpenRounded = Icons.lock_open_rounded;
  static const IconData lockOutlineRounded = Icons.lock_outline_rounded;
  static const IconData checkCircle = Icons.check_circle;
  static const IconData circle = Icons.circle;
  static const IconData schedule = Icons.schedule;
  static const IconData playCircleOutline = Icons.play_circle_outline;
  static const IconData stopCircleOutlined = Icons.stop_circle_outlined;
  static const IconData repeat = Icons.repeat;
  static const IconData quizOutlined = Icons.quiz_outlined;
  static const IconData hourglassEmpty = Icons.hourglass_empty;
  static const IconData timer = Icons.timer;
  static const IconData arrowBackMaterial = Icons.arrow_back;
  static const IconData arrowForwardMaterial = Icons.arrow_forward;
  static const IconData eventNoteRounded = Icons.event_note_rounded;
  static const IconData arrowForwardRounded = Icons.arrow_forward_rounded;
  static const IconData join = Icons.arrow_forward_rounded;
  static const IconData playCircleOutlineRounded =
      Icons.play_circle_outline_rounded;
  static const IconData accessTimeRounded = Icons.access_time_rounded;  
  static const IconData edit = Icons.edit;
  static const IconData uploadFile = Icons.upload_file;
  static const IconData deleteOutline = Icons.delete_outline;
  static const IconData delete = Icons.delete;
  static const IconData pictureAsPdf = Icons.picture_as_pdf;
  static const IconData image = Icons.image;
  static const IconData close = Icons.close;
  static const IconData check = Icons.check;
  static const IconData numbers = Icons.numbers;
  static const IconData signalCellularAlt = Icons.signal_cellular_alt;
  static const IconData cancel = Icons.cancel;
  static const IconData notificationsNone = Icons.notifications_none;
  static const IconData helpOutlineRounded = Icons.help_outline_rounded;
  static const IconData supportAgentRounded = Icons.support_agent_rounded;
  static const IconData checkCircleOutline = Icons.check_circle_outline;
  static const IconData expandLess = Icons.expand_less;
  static const IconData expandMore = Icons.expand_more;
  static const IconData notificationsActive = Icons.notifications_active;
  static const IconData upcoming = Icons.upcoming;
  static const IconData verifiedUser = Icons.verified_user;
  static const IconData visibilityOff = Icons.visibility_off;
  static const IconData arrowForwardIos = Icons.arrow_forward_ios;
  static const IconData peopleAltOutlined = Icons.people_alt_outlined;
  static const IconData analyticsOutlined = Icons.analytics_outlined;
  static const IconData menuBookRounded = Icons.menu_book_rounded;
  static const IconData groups2Outlined = Icons.groups_2_outlined;
  static const IconData calendarMonthOutlined = Icons.calendar_month_outlined;
  static const IconData assignmentOutlined = Icons.assignment_outlined;
  static const IconData groupsRounded = Icons.groups_rounded;
  static const IconData percentRounded = Icons.percent_rounded;
  static const IconData verifiedRounded = Icons.verified_rounded;
  static const IconData trendingUpRounded = Icons.trending_up_rounded;
  static const IconData trendingDownRounded = Icons.trending_down_rounded;
  static const IconData howToVoteOutlined = Icons.how_to_vote_outlined;
  static const IconData groupsOutlined = Icons.groups_outlined;
}
