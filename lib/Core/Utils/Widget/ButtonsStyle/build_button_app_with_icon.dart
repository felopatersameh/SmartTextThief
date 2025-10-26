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
  });
  final String text;
  final String textIcon;
  final Icon iconErrorBuilder;
  final VoidCallback actions;
  final TextStyle? textStyle;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320.w,
      height: 50.h,
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
          side: BorderSide(color: Colors.grey.shade700, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}
