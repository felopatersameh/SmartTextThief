import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';

class ExamsHeaderCard extends StatelessWidget {
  final void Function(String)? onChanged;
  const ExamsHeaderCard({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final Color primary = AppColors.colorPrimary;
    final Color fieldColor = AppColors.textWhite.withValues(alpha: .08);
    final Color hintColor = AppColors.textWhite.withValues(alpha: 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),
        // Search Field
        Container(
          height: 42.h,
          decoration: BoxDecoration(
            color: fieldColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: TextField(
            onChanged: onChanged,
            style: AppTextStyles.bodyMediumMedium.copyWith(
              color: AppColors.textWhite,
            ),
            cursorColor: primary,
            decoration: InputDecoration(
              prefixIcon: Icon(AppIcons.search, color: hintColor, size: 20.sp),
              hintText: SubjectStrings.searchSubjectsHint,
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
        SizedBox(height: 20.h),

        // Row(
        //   children: [
        //     Expanded(
        //       child: Container(
        //         height: 40.h,
        //         decoration: BoxDecoration(
        //           color: fieldColor,
        //           borderRadius: BorderRadius.circular(8.r),
        //         ),
        //         padding: EdgeInsets.symmetric(horizontal: 12.w),
        //         child: DropdownButtonHideUnderline(
        //           child: DropdownButton<String>(
        //             dropdownColor: background,
        //             icon: Icon(
        //               Icons.keyboard_arrow_down,
        //               color: hintColor,
        //               size: 20.sp,
        //             ),
        //             hint: AppCustomtext(
        //               text: 'Exam Type',
        //               textStyle: AppTextStyles.bodyMediumMedium.copyWith(
        //                 color: hintColor,
        //               ),
        //             ),
        //             value: null,
        //             onChanged: (_) {},
        //             items: const [],
        //           ),
        //         ),
        //       ),
        //     ),
        //     SizedBox(width: 8.w),
        //     Expanded(
        //       child: Container(
        //         height: 40.h,
        //         decoration: BoxDecoration(
        //           color: fieldColor,
        //           borderRadius: BorderRadius.circular(8.r),
        //         ),
        //         padding: EdgeInsets.symmetric(horizontal: 12.w),
        //         child: DropdownButtonHideUnderline(
        //           child: DropdownButton<String>(
        //             dropdownColor: background,
        //             icon: Icon(
        //               Icons.keyboard_arrow_down,
        //               color: hintColor,
        //               size: 20.sp,
        //             ),
        //             hint: AppCustomtext(
        //               text: 'Creation Date',
        //               textStyle: AppTextStyles.bodyMediumMedium.copyWith(
        //                 color: hintColor,
        //               ),
        //             ),
        //             value: null,
        //             onChanged: (_) {},
        //             items: const [],
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}
