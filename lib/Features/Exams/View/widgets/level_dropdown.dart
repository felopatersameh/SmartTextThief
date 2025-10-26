import 'package:dropdown_button2/dropdown_button2.dart' as pa;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../Core/Resources/app_colors.dart';
import '../../../../../Core/Resources/app_fonts.dart';
import '../../../../../Core/Utils/Enums/level_exam.dart';
import '../../../../../Core/Utils/Widget/custom_text_app.dart';
import '../../cubit/create/exam_cubit.dart';

class LevelDropdown extends StatelessWidget {
  final CreateExamState state;
  const LevelDropdown({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateExamCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCustomtext(
          text: "Level Exam",
          textStyle: AppTextStyles.h6SemiBold.copyWith(
            color: AppColors.colorPrimary,
          ),
        ),
        SizedBox(height: 6.h),
        DropdownButtonHideUnderline(
          child: pa.DropdownButton2<LevelExam>(
            hint: AppCustomtext(
              text: 'Select Level',
              textStyle: AppTextStyles.bodyMediumMedium,
            ),
            items: LevelExam.values
                .map(
                  (item) => DropdownMenuItem<LevelExam>(
                    value: item,
                    child: Center(
                      child: AppCustomtext(
                        text: item.name,
                        textStyle: AppTextStyles.bodyMediumMedium,
                      ),
                    ),
                  ),
                )
                .toList(),
            dropdownStyleData: pa.DropdownStyleData(
              maxHeight: 200.h,
              elevation: 4,
              decoration: BoxDecoration(
                color: AppColors.colorTextFieldBackGround,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            value: state.selectedLevel,
            onChanged: cubit.changeLevel,
            buttonStyleData: pa.ButtonStyleData(
              height: 50.h,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.colorPrimary, width: 1.4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
