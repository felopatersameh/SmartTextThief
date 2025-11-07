import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/Core/Resources/app_colors.dart';
import '/Core/Resources/app_fonts.dart';
import '/Core/Utils/Widget/custom_text_app.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180.w,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.colorsBackGround2,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          AppCustomText.generate(text: title, textStyle: AppTextStyles.h6Bold),
          SizedBox(height: 4.h),
          AppCustomText.generate(
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
