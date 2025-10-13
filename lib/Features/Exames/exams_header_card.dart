import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Core/Resources/app_colors.dart';
import '../../Core/Resources/app_fonts.dart';
import '../../Core/Utils/Widget/custom_text_app.dart';

class ExamsHeaderCard extends StatelessWidget {
  const ExamsHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = AppColors.colorPrimary;
    final Color background = const Color(
      0xFF0E1621,
    ); // same dark cards background
    final Color fieldColor = Colors.white.withValues(alpha: .08);
    final Color hintColor = Colors.white.withValues(alpha: 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Field
        Container(
          height: 42.h,
          decoration: BoxDecoration(
            color: fieldColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: TextField(
            style: AppTextStyles.bodyMediumMedium.copyWith(color: Colors.white),
            cursorColor: primary,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: hintColor, size: 20.sp),
              hintText: 'Search exams...',
              hintStyle: AppTextStyles.bodyMediumMedium.copyWith(
                color: hintColor,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 10.h,
                horizontal: 12.w,
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),

        // Dropdown Filters Row
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: fieldColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: background,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: hintColor,
                      size: 20.sp,
                    ),
                    hint: AppCustomtext(
                      text: 'Exam Type',
                      textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                        color: hintColor,
                      ),
                    ),
                    value: null,
                    onChanged: (_) {},
                    items: const [],
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: fieldColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: background,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: hintColor,
                      size: 20.sp,
                    ),
                    hint: AppCustomtext(
                      text: 'Creation Date',
                      textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                        color: hintColor,
                      ),
                    ),
                    value: null,
                    onChanged: (_) {},
                    items: const [],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
