import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Core/Resources/app_colors.dart';
import '../../Core/Resources/app_fonts.dart';
import '../../Core/Utils/Widget/custom_text_app.dart';

class ExamCard extends StatelessWidget {
  final String title;
  final String date;
  final String type;
  final VoidCallback? againTest;
  final VoidCallback? pdf;
  final VoidCallback? showQA;

  const ExamCard({
    super.key,
    required this.title,
    required this.date,
    required this.type,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCustomtext(
                    text: title,
                    textStyle: AppTextStyles.bodyLargeBold.copyWith(
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  AppCustomtext(
                    text: 'Created on: $date',
                    textStyle: AppTextStyles.bodySmallMedium.copyWith(
                      color: subtitleColor,
                    ),
                  ),
                  AppCustomtext(
                    text: type,
                    textStyle: AppTextStyles.bodySmallMedium.copyWith(
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10.w),
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
                    Icons.quiz,
                    size: 18.sp,
                    color: primary.withValues(alpha: .8),
                  ),
                  label: AppCustomtext(
                    text: 'Show Questions',
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
              // Download PDF
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: pdf,
                  icon: Icon(Icons.download, color: primary, size: 18.sp),
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
              SizedBox(width: 8.w),
              // Retake Test
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: againTest,
                  icon: Icon(Icons.refresh, size: 18.sp, color: Colors.white),
                  label: AppCustomtext(
                    text: 'Retake Test',
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
