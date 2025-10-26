import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../Core/Utils/Models/exam_model.dart';
import '../../../../Core/Resources/app_colors.dart';
import '../../../../Core/Resources/app_fonts.dart';
import '../../../../Core/Resources/app_icons.dart';
import '../../../../Core/Utils/Widget/custom_text_app.dart';

class ExamCard extends StatelessWidget {
  final ExamModel exam;
  final VoidCallback? againTest;
  final VoidCallback? pdf;
  final VoidCallback? showQA;

  const ExamCard({
    super.key,
    required this.exam,
    this.againTest,
    this.pdf,
    this.showQA,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = AppColors.colorPrimary;
    final Color background = primary.withValues(alpha: 0.13);
    final Color titleColor = Colors.white;
    final Color subtitleColor = Colors.grey.shade600;
    final Color buttonBg = primary.withValues(alpha: 0.1);
    final Color pdfButtonBg = primary.withValues(alpha: 0.1);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppCustomtext(
                          text: exam.examStatic.typeExam.toUpperCase(),
                          textStyle: AppTextStyles.bodyLargeBold.copyWith(
                            color: titleColor,
                          ),
                          textAlign: TextAlign.start,
                          specialText: "#${exam.examId.substring(5, 10)}",
                        ),

                        AppCustomtext(
                          text: exam.isEnded ?
                            "Ended":exam.isStart
                              ? exam.durationAfterStarted
                              : exam.durationBeforeStarted,
                          textStyle: AppTextStyles.bodyXtraSmallMedium.copyWith(
                            color: exam.isEnded
                                ? Colors.redAccent.shade400
                                : exam.isStart
                                ? Colors.green.shade400
                                : Colors.amberAccent.shade400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    AppCustomtext(
                      text: 'Created: ${exam.created}',
                      textStyle: AppTextStyles.bodySmallMedium.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    AppCustomtext(
                      text: 'Start: ${exam.started}',
                      textStyle: AppTextStyles.bodySmallMedium.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    AppCustomtext(
                      text: 'End: ${exam.eneded}',
                      textStyle: AppTextStyles.bodySmallMedium.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                     AppCustomtext(
                      text: 'Q: ${exam.examStatic.numberOfQuestions}',
                      textStyle: AppTextStyles.bodySmallMedium.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    AppCustomtext(
                      text: 'do it : ${exam.examResult.length}',
                      textStyle: AppTextStyles.bodySmallMedium.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              if (exam.isME || (exam.myTest?.isdo ?? false))
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: showQA,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBg,
                      elevation: 0,
                      foregroundColor: primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    icon: Icon(
                      AppIcons.showQuestions,
                      size: 18.sp,
                      color: primary.withValues(alpha: .8),
                    ),
                    label: AppCustomtext(
                      text: exam.isME
                          ? 'Show Questions'
                          : exam.showResult
                          ? "Show Result"
                          : exam.myTest?.isdo ?? false
                          ? "Waiting For Result"
                          : "Testing",
                      textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
                        color: primary.withValues(alpha: .8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),

          // Bottom buttons row
          Row(
            children: [
              // Download PDF - للمعلم فقط
              if (exam.isME)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: pdf,
                    icon: Icon(AppIcons.download, color: primary, size: 18.sp),
                    label: AppCustomtext(
                      text: 'Download PDF',
                      textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                        color: primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: pdfButtonBg,
                      side: BorderSide.none,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              if (exam.isME) SizedBox(width: 8.w),
              // Take Test - للطالب فقط ولو لم يحل الامتحان
              if (!exam.isME && !(exam.myTest?.isdo ?? false))
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: againTest,
                    icon: Icon(AppIcons.quiz, size: 18.sp, color: Colors.white),
                    label: AppCustomtext(
                      text: 'Take Test',
                      textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
