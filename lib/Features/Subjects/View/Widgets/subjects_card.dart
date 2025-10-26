import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_model.dart';
import '../../../../Core/Resources/app_colors.dart';
import '../../../../Core/Resources/app_fonts.dart';
import '../../../../Core/Resources/app_icons.dart';
import '../../../../Core/Utils/Widget/custom_text_app.dart';

class SubjectsCard extends StatelessWidget {
  final SubjectModel model ;
  final VoidCallback? openSubjectDetails;

  const SubjectsCard({
    super.key,

    this.openSubjectDetails, required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = AppColors.colorPrimary;
    final Color background = primary.withValues(alpha: 0.13);
    final Color titleColor = Colors.white;
    final Color subtitleColor = Colors.grey.shade600;
    final String title =model.subjectName;
    final String date =model.createdAt;
    final int lengthStudent =model.subjectEmailSts.length;
    final int examsStudent = model.subjectEmailSts.length;
    return GestureDetector(
      onTap: openSubjectDetails,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppCustomtext(
                    text: title,
                    textStyle: AppTextStyles.bodyLargeBold.copyWith(
                      color: titleColor,
                    ),
                  ),
                ),
                Icon(AppIcons.arrowForward, color: subtitleColor, size: 16.sp),
              ],
            ),
            SizedBox(height: 8.h),

            // Date
            Row(
              children: [
                Icon(AppIcons.calendar, size: 14.sp, color: subtitleColor),
                SizedBox(width: 6.w),
                AppCustomtext(
                  text: 'Created on: $date',
                  textStyle: AppTextStyles.bodySmallMedium.copyWith(
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Stats row
            Row(
              children: [
                // Students
                Expanded(
                  child: Row(
                    children: [
                      Icon(AppIcons.people, size: 16.sp, color: primary),
                      SizedBox(width: 6.w),
                      AppCustomtext(
                        text: '$lengthStudent Students',
                        textStyle: AppTextStyles.bodySmallMedium.copyWith(
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Exams
                Expanded(
                  child: Row(
                    children: [
                      Icon(AppIcons.quiz, size: 16.sp, color: primary),
                      SizedBox(width: 6.w),
                      AppCustomtext(
                        text: '$examsStudent Exams',
                        textStyle: AppTextStyles.bodySmallMedium.copyWith(
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
