import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../Core/Resources/app_colors.dart';
import '../../../../../Core/Resources/app_fonts.dart';
import '../../../../../Core/Utils/Models/exam_exam_result.dart';
import '../../../../../Core/Utils/Widget/custom_text_app.dart';

class StudentSelector extends StatelessWidget {
  final List<ExamResultModel> examResults;
  final String? selectedEmail;
  final Function(String) onSelect;

  const StudentSelector({
    super.key,
    required this.examResults,
    required this.selectedEmail,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.colorsBackGround2,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.colorPrimary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCustomText.generate(
            text: "Select Student",
            textStyle: AppTextStyles.h6SemiBold.copyWith(
              color: AppColors.textWhite,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: examResults.map((result) {
              final isSelected = selectedEmail == result.examResultEmailSt;
              return GestureDetector(
                onTap: () => onSelect(result.examResultEmailSt),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.colorPrimary
                        : AppColors.colorTextFieldBackGround,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.colorPrimary
                          : AppColors.colorPrimary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppCustomText.generate(
                        text: result.examResultEmailSt,
                        textStyle: AppTextStyles.bodySmallMedium.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textWhite,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.2)
                              : AppColors.colorPrimary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: AppCustomText.generate(
                          text: result.examResultDegree,
                          textStyle: AppTextStyles.bodySmallMedium.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.colorPrimary,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
