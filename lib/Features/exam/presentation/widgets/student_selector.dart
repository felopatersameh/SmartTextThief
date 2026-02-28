import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Features/exam/data/models/exam_result_model.dart';
import 'package:smart_text_thief/Core/Utils/Widget/custom_text_app.dart';

class StudentSelector extends StatelessWidget {
  const StudentSelector({
    super.key,
    required this.examResults,
    required this.selectedEmail,
    required this.onSelect,
  });

  final List<ExamResultModel> examResults;
  final String? selectedEmail;
  final ValueChanged<String> onSelect;

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
            text: ViewExamStrings.selectStudent,
            textStyle: AppTextStyles.h6SemiBold.copyWith(
              color: AppColors.textWhite,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: examResults.map((result) {
              final studentEmail = result.student.email;
              final isSelected = selectedEmail == studentEmail;

              return GestureDetector(
                onTap: () => onSelect(studentEmail),
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
                        text: studentEmail,
                        textStyle: AppTextStyles.bodySmallMedium.copyWith(
                          color: AppColors.textWhite,
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
                              ? AppColors.textWhite.withValues(alpha: 0.2)
                              : AppColors.colorPrimary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: AppCustomText.generate(
                          text: '${result.score.degree}',
                          textStyle: AppTextStyles.bodySmallMedium.copyWith(
                            color: isSelected
                                ? AppColors.textWhite
                                : AppColors.colorPrimary,
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

