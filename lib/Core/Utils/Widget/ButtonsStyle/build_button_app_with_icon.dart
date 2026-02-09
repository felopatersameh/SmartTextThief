import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../custom_text_app.dart';

import '../../../Resources/app_fonts.dart';

class BuildButtonAppWithIcon extends StatelessWidget {
  const BuildButtonAppWithIcon({
    super.key,
    required this.text,
    required this.actions,
    this.textStyle,
    required this.textIcon,
    required this.iconErrorBuilder,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
  });
  final String text;
  final String textIcon;
  final Icon iconErrorBuilder;
  final VoidCallback actions;
  final TextStyle? textStyle;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50.h,
      child: OutlinedButton.icon(
        onPressed: actions,
        icon: Image.asset(
          textIcon,
          width: 20.w,
          height: 20.h,
          errorBuilder: (context, error, stackTrace) {
            return iconErrorBuilder;
          },
        ),
        label: AppCustomText.generate(
          text: text,
          textStyle: textStyle ?? AppTextStyles.bodyMediumSemiBold,
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(
            color: borderColor ?? Colors.grey.shade700,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        ),
      ),
    );
  }
}
