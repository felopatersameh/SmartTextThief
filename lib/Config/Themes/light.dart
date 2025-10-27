import 'package:flutter/material.dart';

import '../../Core/Resources/app_colors.dart';
import '../../Core/Resources/app_fonts.dart';

ThemeData lightThemes() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.colorsBackGround,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.colorsBackGround,
      // systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: true,
      titleTextStyle: AppTextStyles.h5Bold,

    ),
    
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // primaryColor: AppColors.primaryColor,
  );
}
