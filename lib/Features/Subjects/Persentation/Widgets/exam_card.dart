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
    // final Color buttonBg = primary.withValues(alpha: 0.1);
    // final Color pdfButtonBg = primary.withValues(alpha: 0.1);

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
                        SizedBox(width: 8.w),
                        // Exam status badge
                        _buildExamStatusBadge(),
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
            ],
          ),
          SizedBox(height: 16.h),

          // Exam status message and action button
          _buildExamStatusSection(),
        ],
      ),
    );
  }

  Widget _buildExamStatusBadge() {
    if (exam.isEnded) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
        ),
        child: AppCustomText.generate(
          text: "Ended",
          textStyle: AppTextStyles.bodyExtraSmallMedium.copyWith(
            color: Colors.redAccent.shade400,
          ),
        ),
      );
    } else if (exam.isStart) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
        ),
        child: AppCustomText.generate(
          text: "Live",
          textStyle: AppTextStyles.bodyExtraSmallMedium.copyWith(
            color: Colors.green.shade400,
          ),
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.amberAccent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4)),
        ),
        child: AppCustomText.generate(
          text: "Upcoming",
          textStyle: AppTextStyles.bodyExtraSmallMedium.copyWith(
            color: Colors.amberAccent.shade400,
          ),
        ),
      );
    }
  }

  Widget _buildExamStatusSection() {
    final Color primary = AppColors.colorPrimary;

    if (exam.isTeacher) {
      return Row(
        children: [
          // View Results Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: showQA,
              icon: Icon(
                AppIcons.showQuestions,
                size: 18.sp,
                color: Colors.white,
              ),
              label: AppCustomText.generate(
                text: 'View Results',
                textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Download PDF Button
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
                backgroundColor: primary.withValues(alpha: 0.1),
                side: BorderSide.none,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // For students
    if (!exam.isStart) {
      // Exam hasn't started yet
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCustomText.generate(
            text: 'Starts in: ${exam.durationBeforeStarted}',
            textStyle: AppTextStyles.bodySmallMedium.copyWith(
              color: Colors.amberAccent.shade400,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
            ),
            child: AppCustomText.generate(
              text: 'Waiting for exam to start...',
              textStyle: AppTextStyles.bodySmallMedium.copyWith(
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    } else if (exam.isStart && !exam.isEnded) {
      // Exam is ongoing
      if (exam.doExam) {
        // Student has taken the exam
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCustomText.generate(
              text: 'Time remaining: ${exam.durationAfterStarted}',
              textStyle: AppTextStyles.bodySmallMedium.copyWith(
                color: Colors.green.shade400,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.4)),
              ),
              child: AppCustomText.generate(
                text: 'Waiting for results after exam ends...',
                textStyle: AppTextStyles.bodySmallMedium.copyWith(
                  color: Colors.blue.shade400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      } else {
        // Student hasn't taken the exam yet
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCustomText.generate(
              text: 'Time remaining: ${exam.durationAfterStarted}',
              textStyle: AppTextStyles.bodySmallMedium.copyWith(
                color: Colors.green.shade400,
              ),
            ),
            SizedBox(height: 12.h),
            ElevatedButton.icon(
              onPressed: againTest,
              icon: Icon(AppIcons.quiz, size: 18.sp, color: Colors.white),
              label: AppCustomText.generate(
                text: 'Start Exam',
                textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                minimumSize: Size(double.infinity, 0),
              ),
            ),
          ],
        );
      }
    } else {
      // Exam has ended
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: showQA,
              icon: Icon(
                AppIcons.showQuestions,
                size: 18.sp,
                color: Colors.white,
              ),
              label: AppCustomText.generate(
                text: 'Show Result',
                textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ],
      );
    }
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
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
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
