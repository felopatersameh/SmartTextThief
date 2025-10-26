import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/Core/Resources/resources.dart';
import '/Core/Utils/Widget/custom_text_app.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const InfoRow({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 14.sp),
          SizedBox(width: 6.w),
          AppCustomText.generate(
            text: label,
            textStyle: AppTextStyles.bodySmallMedium.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
