import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Utils/Widget/custom_text_app.dart';

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
    final year = DateTime.now().year + AppConstants.maxDatePickerYearsAhead;
    final initialDate =
        isStart ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(year),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.colorPrimary,
              onPrimary: AppColors.textWhite,
              surface: AppColors.colorsBackGround2,
              onSurface: AppColors.textWhite,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.colorPrimary,
              ),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.colorsBackGround2,
            ),
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
    return "${date.day} ${AppList.monthsShort[date.month - 1]} ${date.year}";
  }

  String _getWeekDay(DateTime date) {
    return AppList.weekDaysShort[date.weekday - 1];
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
                  AppIcons.eventNoteRounded,
                  color: AppColors.colorPrimary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              AppCustomText.generate(
                text: CreateExamStrings.examDuration,
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
                    label: CreateExamStrings.startDate,
                    date: startDate,
                    icon: AppIcons.playCircleOutlineRounded,
                    formatDate: _formatDate,
                    getWeekDay: _getWeekDay,
                    isEditable: isEditMode,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Icon(
                AppIcons.arrowForwardRounded,
                color: AppColors.colorPrimary,
                size: 18.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickDate(context, false),
                  child: _DateCard(
                    label: CreateExamStrings.endDate,
                    date: endDate,
                    icon: AppIcons.stopCircleOutlined,
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
                    AppIcons.accessTimeRounded,
                    color: AppColors.colorPrimary,
                    size: 16.sp,
                  ),
                  SizedBox(width: 6.w),
                  AppCustomText.generate(
                    text:
                        "${CreateExamStrings.duration}: ${endDate!.difference(startDate!).inDays} ${CreateExamStrings.days}",
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
      duration: AppConstants.animationFast,
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
                    AppIcons.edit,
                    size: 12.sp,
                    color: AppColors.colorPrimary.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),

          /// Date Text
          AppCustomText.generate(
            text: hasDate ? formatDate(date!) : CreateExamStrings.selectDate,
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
