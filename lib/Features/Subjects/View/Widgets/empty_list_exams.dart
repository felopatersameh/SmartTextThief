import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icon_broken/icon_broken.dart';
import 'package:smart_text_thief/Core/Resources/app_fonts.dart';

class EmptyListExams extends StatelessWidget {
  const EmptyListExams({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconBroken.Document,
            size: 64.sp,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          SizedBox(height: 12.h),
          Text(
            'No exams available currently',
            style: AppTextStyles.bodyLargeSemiBold.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            'Check back later for new exams ✨',
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
