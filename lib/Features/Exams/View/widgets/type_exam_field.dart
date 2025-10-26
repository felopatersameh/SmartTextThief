import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../Core/Resources/app_colors.dart';
import '../../../../../Core/Resources/app_fonts.dart';
import '../../../../../Core/Utils/Widget/custom_text_app.dart';
import '../../cubit/create/exam_cubit.dart';

class TypeExamField extends StatelessWidget {
  const TypeExamField({super.key, required this.state}); final CreateExamState state;


  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateExamCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCustomtext(
          text: "Type of Exam",
          textStyle: AppTextStyles.h6SemiBold.copyWith(color: AppColors.colorPrimary),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          initialValue: state.type,
          onChanged: cubit.changeType,
          style: AppTextStyles.bodyMediumMedium,
          decoration: InputDecoration(
            hintText: 'Enter exam type',
            hintStyle: AppTextStyles.bodySmallMedium.copyWith(color: Colors.grey),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.colorPrimary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
