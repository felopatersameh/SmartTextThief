import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../Core/Resources/app_colors.dart';
import '../../../../../../Core/Resources/app_fonts.dart';
import '../../../../../../Core/Utils/Widget/custom_text_app.dart';

class ExamDateSection extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isEditMode;
  final Function(DateTime)? onStartChanged;
  final Function(DateTime)? onEndChanged;

  const ExamDateSection({
    super.key,
    required this.startDate,
    required this.endDate,
    this.isEditMode = true,
    this.onStartChanged,
    this.onEndChanged,
  });

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    if (!isEditMode) return;

    final initialDate = isStart
        ? (startDate ?? DateTime.now())
        : (endDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.colorPrimary,
              onPrimary: Colors.white,
              surface: AppColors.colorsBackGround2,
              onSurface: AppColors.textWhite,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.colorPrimary,
              ),
            ), dialogTheme: DialogThemeData(backgroundColor: AppColors.colorsBackGround2),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStart) {
        onStartChanged?.call(picked);
      } else {
        onEndChanged?.call(picked);
      }
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  String _getWeekDay(DateTime date) {
    const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekDays[date.weekday - 1];
  }

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
        boxShadow: [
          BoxShadow(
            color: AppColors.colorPrimary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// === Header ===
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.colorPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.event_note_rounded,
                  color: AppColors.colorPrimary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              AppCustomText.generate(
                text: "Exam Duration",
                textStyle: AppTextStyles.h6SemiBold.copyWith(
                  color: AppColors.textWhite,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          /// === Date Fields ===
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickDate(context, true),
                  child: _DateCard(
                    label: "Start Date",
                    date: startDate,
                    icon: Icons.play_circle_outline_rounded,
                    formatDate: _formatDate,
                    getWeekDay: _getWeekDay,
                    isEditable: isEditMode,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.colorPrimary,
                size: 18.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickDate(context, false),
                  child: _DateCard(
                    label: "End Date",
                    date: endDate,
                    icon: Icons.stop_circle_outlined,
                    formatDate: _formatDate,
                    getWeekDay: _getWeekDay,
                    isEditable: isEditMode,
                  ),
                ),
              ),
            ],
          ),

          /// === Duration Info ===
          if (startDate != null && endDate != null)
            Container(
              margin: EdgeInsets.only(top: 12.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.colorPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.colorPrimary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: AppColors.colorPrimary,
                    size: 16.sp,
                  ),
                  SizedBox(width: 6.w),
                  AppCustomText.generate(
                    text:
                        "Duration: ${endDate!.difference(startDate!).inDays} days",
                    textStyle: AppTextStyles.bodySmallMedium.copyWith(
                      color: AppColors.colorPrimary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  final String label;
  final DateTime? date;
  final IconData icon;
  final String Function(DateTime) formatDate;
  final String Function(DateTime) getWeekDay;
  final bool isEditable;

  const _DateCard({
    required this.label,
    required this.date,
    required this.icon,
    required this.formatDate,
    required this.getWeekDay,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.colorTextFieldBackGround,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: hasDate
              ? AppColors.colorPrimary
              : AppColors.colorPrimary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: hasDate
            ? [
                BoxShadow(
                  color: AppColors.colorPrimary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Label
          Row(
            children: [
              Icon(
                icon,
                color: hasDate
                    ? AppColors.colorPrimary
                    : AppColors.colorPrimary.withValues(alpha: 0.5),
                size: 18.sp,
              ),
              SizedBox(width: 6.w),
              AppCustomText.generate(
                text: label,
                textStyle: AppTextStyles.bodySmallMedium.copyWith(
                  color: AppColors.textCoolGray,
                  fontSize: 11.sp,
                ),
              ),
              if (isEditable)
                Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Icon(
                    Icons.edit,
                    size: 12.sp,
                    color: AppColors.colorPrimary.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),

          /// Date Text
          AppCustomText.generate(
            text: hasDate ? formatDate(date!) : "Select Date",
            textStyle: AppTextStyles.bodyMediumMedium.copyWith(
              color: hasDate ? AppColors.textWhite : AppColors.textCoolGray,
              fontSize: 13.sp,
              fontWeight: hasDate ? FontWeight.w600 : FontWeight.w400,
            ),
          ),

          /// Weekday Tag
          if (hasDate) ...[
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.colorPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: AppCustomText.generate(
                text: getWeekDay(date!),
                textStyle: AppTextStyles.bodySmallMedium.copyWith(
                  color: AppColors.colorPrimary,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
