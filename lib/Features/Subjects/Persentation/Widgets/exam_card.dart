import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Core/Resources/app_colors.dart';
import 'package:smart_text_thief/Core/Resources/app_fonts.dart';
import 'package:smart_text_thief/Core/Resources/app_icons.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/Widget/custom_text_app.dart';

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
    return Container(
      margin: EdgeInsets.only(bottom: 12.h, left: 16.w, right: 16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.colorPrimary.withValues(alpha: 0.12),
            AppColors.colorPrimary.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Row(
              children: [
                // Exam Type & ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppCustomText.generate(
                        text: exam.examStatic.typeExam.toUpperCase(),
                        textStyle: AppTextStyles.bodyLargeBold.copyWith(
                          color: Colors.white,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      AppCustomText.generate(
                        text: '#${exam.examId.substring(5, 10)}',
                        textStyle: AppTextStyles.bodySmallMedium.copyWith(
                          color: Colors.grey.shade400,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                _buildStatusBadge(),
              ],
            ),
          ),

          // Content Section
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              children: [
                // Info Grid
                _buildInfoGrid(),

                SizedBox(height: 14.h),

                // Action Section
                _buildActionSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    if (exam.isEnded) {
      badgeColor = Colors.red;
      badgeText = 'Ended';
      badgeIcon = Icons.check_circle;
    } else if (exam.isStart) {
      badgeColor = Colors.green;
      badgeText = 'Live';
      badgeIcon = Icons.circle;
    } else {
      badgeColor = Colors.amber;
      badgeText = 'Upcoming';
      badgeIcon = Icons.schedule;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, color: badgeColor, size: 12.sp),
          SizedBox(width: 4.w),
          AppCustomText.generate(
            text: badgeText,
            textStyle: AppTextStyles.bodySmallBold.copyWith(
              color: badgeColor,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Column(
      children: [
        Row(
          children: [
            // Expanded(
            //   child: _buildInfoItem(
            //     icon: Icons.calendar_today,
            //     label: 'Created',
            //     value: exam.created,
            //     color: Colors.blue,
            //   ),
            // ),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.play_circle_outline,
                label: 'Start',
                value: exam.started,
                color: Colors.green,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.stop_circle_outlined,
                label: 'End',
                value: exam.ended,
                color: Colors.red,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.repeat,
                label: 'Attempts',
                value: '${exam.examResult.length}',
                color: Colors.purple,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.quiz_outlined,
                label: 'Questions',
                value: '${exam.examStatic.numberOfQuestions}',
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(icon, color: color, size: 14.sp),
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
                    fontSize: 10.sp,
                  ),
                ),
                AppCustomText.generate(
                  text: value,
                  textStyle: AppTextStyles.bodySmallBold.copyWith(
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    // final Color primary = AppColors.colorPrimary;

    if (exam.isTeacher) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildActionButton(
              onPressed: showQA,
              icon: AppIcons.showQuestions,
              label: 'View Results',
              isPrimary: true,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 2,
            child: _buildActionButton(
              onPressed: pdf,
              icon: AppIcons.download,
              label: 'PDF',
              isPrimary: false,
            ),
          ),
        ],
      );
    }

    if (!exam.isStart) {
      return _buildInfoMessage(
        message: 'Exam starts in ${exam.durationBeforeStarted}',
        icon: Icons.schedule,
        color: Colors.amber,
      );
    } else if (exam.isStart && !exam.isEnded) {
      if (exam.doExam) {
        return _buildInfoMessage(
          message: 'Waiting for results...',
          subtitle: 'Time left: ${exam.durationAfterStarted}',
          icon: Icons.hourglass_empty,
          color: Colors.blue,
        );
      } else {
        return Column(
          children: [
            _buildInfoMessage(
              message: 'Time remaining: ${exam.durationAfterStarted}',
              icon: Icons.timer,
              color: Colors.green,
              compact: true,
            ),
            SizedBox(height: 10.h),
            _buildActionButton(
              onPressed: againTest,
              icon: AppIcons.quiz,
              label: 'Start Exam Now',
              isPrimary: true,
              fullWidth: true,
            ),
          ],
        );
      }
    } else {
      return _buildActionButton(
        onPressed: showQA,
        icon: AppIcons.showQuestions,
        label: 'Show My Results',
        isPrimary: true,
        fullWidth: true,
      );
    }
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
    bool fullWidth = false,
  }) {
    final Color primary = AppColors.colorPrimary;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? primary : primary.withValues(alpha: 0.15),
        foregroundColor: isPrimary ? Colors.white : primary,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
          side: isPrimary
              ? BorderSide.none
              : BorderSide(color: primary.withValues(alpha: 0.3), width: 1.2),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp),
          SizedBox(width: 6.w),
          AppCustomText.generate(
            text: label,
            textStyle: AppTextStyles.bodySmallBold.copyWith(
              color: isPrimary ? Colors.white : primary,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoMessage({
    required String message,
    String? subtitle,
    required IconData icon,
    required Color color,
    bool compact = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 10.h : 12.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCustomText.generate(
                  text: message,
                  textStyle: AppTextStyles.bodySmallBold.copyWith(
                    color: color,
                    fontSize: 12.sp,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2.h),
                  AppCustomText.generate(
                    text: subtitle,
                    textStyle: AppTextStyles.bodySmallMedium.copyWith(
                      color: Colors.grey.shade400,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
