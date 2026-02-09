import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../Core/Resources/resources.dart';

class LoginIndicators extends StatelessWidget {
  const LoginIndicators({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: AppConstants.animationMedium,
          curve: Curves.easeOut,
          width: currentIndex == index ? 22.w : 8.w,
          height: 8.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: currentIndex == index
                ? AppColors.colorPrimary
                : AppColors.colorUnActiveIcons.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}
