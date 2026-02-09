import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../Core/Resources/resources.dart';

class OnboardingCard extends StatelessWidget {
  const OnboardingCard({
    super.key,
    required this.item,
    required this.compact,
  });

  final OnboardingItemData item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tiny = MediaQuery.sizeOf(context).height < 620;
    final iconSize = tiny
        ? 48.r
        : compact
            ? 56.r
            : 64.r;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14.w : 16.w,
        vertical: compact ? 14.h : 16.h,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.colorTextFieldBackGround.withValues(alpha: 0.78),
            AppColors.colorsBackGround2.withValues(alpha: 0.96),
          ],
        ),
        border: Border.all(
          color: AppColors.colorPrimary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: AppColors.colorPrimary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.colorPrimary.withValues(alpha: 0.35),
              ),
            ),
            child: Icon(
              item.icon,
              color: AppColors.colorPrimary,
              size: tiny
                  ? 22.sp
                  : compact
                      ? 25.sp
                      : 28.sp,
            ),
          ),
          SizedBox(height: tiny ? 8.h : 12.h),
          Text(
            item.title,
            textAlign: TextAlign.center,
            maxLines: tiny ? 1 : 2,
            style: (tiny ? AppTextStyles.bodyLargeBold : AppTextStyles.h6Bold)
                .copyWith(overflow: TextOverflow.ellipsis),
          ),
          SizedBox(height: tiny ? 6.h : 10.h),
          Text(
            item.description,
            textAlign: TextAlign.center,
            maxLines: tiny
                ? 2
                : compact
                    ? 4
                    : 5,
            style:
                (tiny ? AppTextStyles.bodySmallMedium : AppTextStyles.bodyMediumMedium)
                    .copyWith(
              color: AppColors.textCoolGray,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
