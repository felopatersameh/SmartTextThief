import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../Core/Resources/resources.dart';

ThemeData darkThemes() {
  return ThemeData(
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
      backgroundColor: AppColors.colorsBackGround,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: true,
      titleTextStyle: AppTextStyles.h5Bold,
    ),
  );
}
