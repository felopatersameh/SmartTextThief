import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/Core/Resources/resources.dart';
import '/Core/Utils/Widget/custom_text_app.dart';

class OptionTile extends StatelessWidget {
  const OptionTile({super.key, required this.title, this.onTap, this.color});

  final String title;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.h),
      margin: EdgeInsets.symmetric(vertical: 5.h),
      decoration: BoxDecoration(
        color: color ?? AppColors.colorsBackGround2,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: AppColors.transparent,
          highlightColor: AppColors.transparent,
          hoverColor: AppColors.transparent,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: AppCustomText.generate(
            text: title,
            textStyle: AppTextStyles.h6Bold,
          ),
          trailing: Icon(
            AppIcons.arrowForwardIos,
            size: 18.sp,
            color: AppColors.textWhite,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
