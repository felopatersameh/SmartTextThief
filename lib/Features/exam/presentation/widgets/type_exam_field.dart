import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Utils/Widget/custom_text_app.dart';

class ExamField extends StatelessWidget {
  const ExamField({
    super.key,
    required this.title,
    required this.hint,
    required this.initialValue,
    this.onChanged,
  });
  final String title;
  final String hint;
  final String initialValue;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCustomText.generate(
          text: title,
          textStyle: AppTextStyles.h6SemiBold.copyWith(
            color: AppColors.colorPrimary,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          style: AppTextStyles.bodyMediumMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmallMedium.copyWith(
              color: AppColors.grey,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 10.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.colorPrimary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
