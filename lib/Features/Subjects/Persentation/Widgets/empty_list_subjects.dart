import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icon_broken/icon_broken.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';

class EmptyListSubjects extends StatelessWidget {
  const EmptyListSubjects({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconBroken.Bookmark,
            size: 70.sp,
            color: AppColors.grey.withValues(alpha: 0.5),
          ),
          SizedBox(height: 12.h),
          Text(
            SubjectStrings.noSubjectsAvailable,
            style: AppTextStyles.bodyLargeSemiBold.copyWith(
              color: AppColors.grey500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            SubjectStrings.noSubjectsAvailableHint,
            style: AppTextStyles.bodyMediumMedium.copyWith(
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
