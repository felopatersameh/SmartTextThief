import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Core/Resources/app_colors.dart';
import 'package:smart_text_thief/Core/Resources/app_fonts.dart';
import 'package:smart_text_thief/Core/Utils/Widget/custom_text_app.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.w,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.colorsBackGround2,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          AppCustomtext(text: title, textStyle: AppTextStyles.h6Bold),
          SizedBox(height: 4.h),
          AppCustomtext(
            text: subtitle,
            textStyle: AppTextStyles.bodySmallSemiBold.copyWith(
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}
