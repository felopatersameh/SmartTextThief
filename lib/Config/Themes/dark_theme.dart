import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../Core/Resources/resources.dart';

ThemeData darkThemes() {
   return ThemeData(
    scaffoldBackgroundColor: AppColors.colorsBackGround,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.colorsBackGround,
      iconTheme: IconThemeData(
        color: Colors.white,
        shadows: [
          Shadow(blurRadius: 4.0, color: Colors.black, offset: Offset(0, 2)),
        ],
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
      ),
      centerTitle: true,
      titleTextStyle: AppTextStyles.h5Bold,
    ),
    brightness: Brightness.light,

    // primaryColor: AppColors.primaryColor,
  );
}
