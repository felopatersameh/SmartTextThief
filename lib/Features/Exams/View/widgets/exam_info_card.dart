import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../Core/Resources/app_colors.dart';
import '../../../../Core/Resources/app_fonts.dart';
import '../../../../Core/Utils/Models/exam_model.dart';
import '../../../../Core/Utils/Widget/custom_text_app.dart';

class ExamInfoCard extends StatelessWidget {
  final ExamModel exam;

  const ExamInfoCard({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.colorsBackGround2,
            AppColors.colorsBackGround2.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.colorPrimary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            icon: Icons.quiz,
            label: "Type",
            value: exam.examStatic.typeExam,
          ),
          SizedBox(height: 8.h),
          _InfoRow(
            icon: Icons.signal_cellular_alt,
            label: "Level",
            value: exam.examStatic.levelExam.name,
          ),
          SizedBox(height: 8.h),
          _InfoRow(
            icon: Icons.numbers,
            label: "Questions",
            value: exam.examStatic.numberOfQuestions.toString(),
          ),
          SizedBox(height: 8.h),
          _InfoRow(
            icon: Icons.shuffle,
            label: "Random",
            value: exam.examStatic.randomQuestions ? "Yes" : "No",
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.colorPrimary, size: 20.sp),
        SizedBox(width: 8.w),
        AppCustomText.generate(
          text: "$label: ",
          textStyle: AppTextStyles.bodyMediumMedium.copyWith(
            color: AppColors.textCoolGray,
          ),
        ),
        AppCustomText.generate(
          text: value,
          textStyle: AppTextStyles.bodyMediumMedium.copyWith(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
