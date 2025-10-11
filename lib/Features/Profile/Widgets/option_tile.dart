import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Core/Resources/app_colors.dart';
import 'package:smart_text_thief/Core/Resources/app_fonts.dart';
import 'package:smart_text_thief/Core/Utils/Widget/custom_text_app.dart';

class OptionTile extends StatelessWidget {
  const OptionTile({super.key, required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.h),
      margin: EdgeInsets.symmetric(vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.colorsBackGround2,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: AppCustomtext(text: title, textStyle: AppTextStyles.h6Bold),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18.sp,
          color: Colors.white,
        ),
        onTap: onTap,
      ),
    );
  }
}
