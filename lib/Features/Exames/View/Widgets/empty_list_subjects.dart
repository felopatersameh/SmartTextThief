import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icon_broken/icon_broken.dart';
import '../../../../Core/Resources/app_fonts.dart';

class EmptyListSubjects extends StatelessWidget {
  const EmptyListSubjects({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconBroken.Bookmark, 
            size: 70.sp,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          SizedBox(height: 12.h),
          Text(
            'No subjects available currently',
            style: AppTextStyles.bodyLargeSemiBold.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            'When new subjects are added, they will appear here 📚',
            style: AppTextStyles.bodyMediumMedium.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
