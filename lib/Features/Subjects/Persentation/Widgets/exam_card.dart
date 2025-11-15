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
                        AppCustomText.generate(
                          text: exam.examStatic.typeExam.toUpperCase(),
                          textStyle: AppTextStyles.bodyLargeBold.copyWith(
                            color: titleColor,
                          ),
                          textAlign: TextAlign.start,
                          specialText: "#${exam.examId.substring(5, 10)}",
                        ),
                        AppCustomText.generate(
                          text: exam.isEnded
                              ? "Ended"
                              : exam.isStart
                                  ? exam.durationAfterStarted
                                  : exam.durationBeforeStarted,
                          textStyle: AppTextStyles.bodyExtraSmallMedium.copyWith(
                            color: exam.isEnded
                                ? Colors.redAccent.shade400
                                : exam.isStart
                                    ? Colors.green.shade400
                                    : Colors.amberAccent.shade400,
                          ),
                        ),
                      ],
                    ),
                    
                    // Enhanced Info Section - Horizontal Scroll Chips
                    SizedBox(height: 12.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCompactChip(
                            label: 'Created',
                            value: exam.created,
                            color: Colors.blueAccent,
                          ),
                          SizedBox(width: 8.w),
                          _buildCompactChip(
                            label: 'Start',
                            value: exam.started,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8.w),
                          _buildCompactChip(
                            label: 'End',
                            value: exam.ended,
                            color: Colors.redAccent,
                          ),
                          SizedBox(width: 8.w),
                          _buildCompactChip(
                            label: 'Questions',
                            value: '${exam.examStatic.numberOfQuestions}',
                            color: Colors.orangeAccent,
                          ),
                          SizedBox(width: 8.w),
                          _buildCompactChip(
                            label: 'Attempts',
                            value: '${exam.examResult.length}',
                            color: Colors.purpleAccent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: showQA,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBg,
                      elevation: 0,
                      foregroundColor: primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppIcons.showQuestions,
                          size: 24.sp,
                          color: primary,
                        ),
                        SizedBox(height: 4.h),
                        AppCustomText.generate(
                          text: exam.isTeacher
                              ? 'View'
                              : exam.isEnded
                                  ? 'Result'
                                  : exam.doExam
                                      ? 'Done'
                                      : 'Pending',
                          textStyle: AppTextStyles.bodyExtraSmallSemiBold.copyWith(
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
          SizedBox(height: 16.h),

          // Bottom buttons row
          Row(
            children: [
              if (exam.isTeacher)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: pdf,
                    icon: Icon(AppIcons.download, color: primary, size: 18.sp),
                    label: AppCustomText.generate(
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
              if (exam.isTeacher) SizedBox(width: 8.w),
              if (!exam.isTeacher && !(exam.showResult))
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: againTest,
                    icon: Icon(AppIcons.quiz, size: 18.sp, color: Colors.white),
                    label: AppCustomText.generate(
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

  Widget _buildCompactChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppCustomText.generate(
            text: '$label: ',
            textStyle: AppTextStyles.bodyExtraSmallMedium.copyWith(
              color: color,
            ),
          ),
          AppCustomText.generate(
            text: value,
            textStyle: AppTextStyles.bodySmallSemiBold.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}