import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/Core/Resources/resources.dart';

class LoadingIndicator extends StatelessWidget {
  final AnimationController controller;

  const LoadingIndicator({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = controller.value.clamp(0.0, 1.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: AppIcons.splash,
            ),
            SizedBox(height: 30.h),
            Text(
              AppStrings.loading,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.grey700,
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              width: 200.w,
              height: 6.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppColors.grey300,
              ),
              child: Stack(
                children: [
                  Container(
                    width: 200.w * value,
                    height: 6.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.blue.withValues(alpha: 0.6),
                          AppColors.blue.withValues(alpha: 0.8),
                          AppColors.blue,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(fontSize: 14.sp, color: AppColors.grey600),
            ),
          ],
        );
      },
    );
  }
}
