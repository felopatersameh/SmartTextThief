import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Features/exam/data/models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/Widget/custom_text_app.dart';

class ExamInfoCard extends StatelessWidget {
  const ExamInfoCard({
    super.key,
    required this.exam,
  });

  final ExamModel exam;

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
          _InfoRow(
            icon: AppIcons.signalCellularAlt,
            label: ViewExamStrings.level,
            value: exam.levelExam,
          ),
          SizedBox(height: 8.h),
          _InfoRow(
            icon: AppIcons.numbers,
            label: ViewExamStrings.questions,
            value: exam.questions.length.toString(),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.colorPrimary,
          size: 20.sp,
        ),
        SizedBox(width: 8.w),
        AppCustomText.generate(
          text: '$label: ',
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

