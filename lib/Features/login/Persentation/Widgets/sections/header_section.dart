import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../Core/Resources/resources.dart';

class LoginHeaderSection extends StatelessWidget {
  const LoginHeaderSection({
    super.key,
    required this.compact,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: compact ? 12.h : 14.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.colorsBackGround2.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.colorPrimary.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 58.r : 66.r,
            height: compact ? 58.r : 66.r,
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.colorPrimary.withValues(alpha: 0.14),
              border: Border.all(
                color: AppColors.colorPrimary.withValues(alpha: 0.35),
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                AppConstants.appLogoAsset,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.welcome,
                  maxLines: 1,
                  style: (compact ? AppTextStyles.h6Bold : AppTextStyles.h5Bold)
                      .copyWith(overflow: TextOverflow.ellipsis),
                ),
                SizedBox(height: 2.h),
                Text(
                  AppStrings.welcomeHint,
                  maxLines: 2,
                  style: AppTextStyles.bodySmallMedium.copyWith(
                    color: AppColors.textCoolGray,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
