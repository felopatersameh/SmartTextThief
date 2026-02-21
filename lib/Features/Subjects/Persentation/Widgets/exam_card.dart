import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
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
          color: AppColors.textWhite.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.15),
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
                        text: exam.levelExam.toUpperCase(),
                        textStyle: AppTextStyles.bodyLargeBold.copyWith(
                          color: AppColors.textWhite,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      AppCustomText.generate(
                        text: '#${exam.id.substring(5, 10)}',
                        textStyle: AppTextStyles.bodySmallMedium.copyWith(
                          color: AppColors.grey400,
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
      badgeColor = AppColors.danger;
      badgeText = ExamCardStrings.ended;
      badgeIcon = AppIcons.checkCircle;
    } else if (exam.isStart) {
      badgeColor = AppColors.success;
      badgeText = ExamCardStrings.live;
      badgeIcon = AppIcons.circle;
    } else {
      badgeColor = AppColors.amber;
      badgeText = ExamCardStrings.upcoming;
      badgeIcon = AppIcons.schedule;
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
                icon: AppIcons.playCircleOutline,
                label: ExamCardStrings.start,
                value: exam.started,
                color: AppColors.success,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildInfoItem(
                icon: AppIcons.stopCircleOutlined,
                label: ExamCardStrings.end,
                value: exam.ended,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: AppIcons.repeat,
                label: ExamCardStrings.attempts,
                value: '${0}',
                color: AppColors.purple,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildInfoItem(
                icon: AppIcons.quizOutlined,
                label: ExamCardStrings.questions,
                value: '${exam.questionCount}',
                color: AppColors.orange,
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
        color: AppColors.textWhite.withValues(alpha: 0.03),
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
                    color: AppColors.grey400,
                    fontSize: 10.sp,
                  ),
                ),
                AppCustomText.generate(
                  text: value,
                  textStyle: AppTextStyles.bodySmallBold.copyWith(
                    color: AppColors.textWhite,
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

    if (exam.doExam) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildActionButton(
              onPressed: showQA,
              icon: AppIcons.showQuestions,
              label: ExamCardStrings.viewResults,
              isPrimary: true,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 2,
            child: _buildActionButton(
              onPressed: pdf,
              icon: AppIcons.download,
              label: ExamCardStrings.pdf,
              isPrimary: false,
            ),
          ),
        ],
      );
    }

    if (!exam.isStart) {
      return _buildInfoMessage(
        message: ExamCardStrings.examStartsIn(exam.durationBeforeStarted),
        icon: AppIcons.schedule,
        color: AppColors.amber,
      );
    } else if (exam.isStart && !exam.isEnded) {
      if (exam.doExam) {
        return _buildInfoMessage(
          message: ExamCardStrings.waitingForResults,
          subtitle: ExamCardStrings.timeLeft(exam.durationAfterStarted),
          icon: AppIcons.hourglassEmpty,
          color: AppColors.blue,
        );
      } else {
        return Column(
          children: [
            _buildInfoMessage(
              message: ExamCardStrings.timeRemaining(exam.durationAfterStarted),
              icon: AppIcons.timer,
              color: AppColors.success,
              compact: true,
            ),
            SizedBox(height: 10.h),
            _buildActionButton(
              onPressed: againTest,
              icon: AppIcons.quiz,
              label: ExamCardStrings.startExamNow,
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
        label: ExamCardStrings.showMyResults,
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
        foregroundColor: isPrimary ? AppColors.textWhite : primary,
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
              color: isPrimary ? AppColors.textWhite : primary,
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
                      color: AppColors.grey400,
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
