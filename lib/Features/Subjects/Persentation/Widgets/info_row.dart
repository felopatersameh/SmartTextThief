import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/Core/Resources/resources.dart';
import '/Core/Utils/Widget/custom_text_app.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(icon, color: AppColors.colorPrimary, size: 14.sp),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCustomText.generate(
                  text: label,
                  textStyle: AppTextStyles.bodySmallMedium.copyWith(
                    color: Colors.grey.shade400,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 1.h),
                AppCustomText.generate(
                  text: value,
                  textStyle: AppTextStyles.bodySmallBold.copyWith(
                    color: Colors.white,
                    fontSize: 13.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}