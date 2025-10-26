import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Resources/app_fonts.dart';
import '../custom_text_app.dart';

import '../../../Resources/app_colors.dart';

class BuildButtonApp extends StatelessWidget {
  const BuildButtonApp({
    super.key,
    required this.text,
    required this.actions,
    this.background,
    this.textStyle,
  });
  final String text;
  final VoidCallback actions;
  final Color? background;
  final TextStyle? textStyle;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320.w,
      height: 50.h,
      child: ElevatedButton(
        onPressed: actions,
        style: ElevatedButton.styleFrom(
          backgroundColor: background ?? AppColors.colorPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: AppCustomText.generate(
          text: text,
          textStyle: textStyle ?? AppTextStyles.bodyLargeMedium,
        ),
      ),
    );
  }
}
