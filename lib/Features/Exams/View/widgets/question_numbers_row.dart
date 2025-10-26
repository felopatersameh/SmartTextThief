import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../Core/Resources/app_colors.dart';
import '../../../../../Core/Resources/app_fonts.dart';
import '../../../../../Core/Utils/Widget/custom_text_app.dart';
import '../../cubit/create/exam_cubit.dart';

class QuestionNumbersRow extends StatelessWidget {
  const QuestionNumbersRow({super.key, required this.state});
  final CreateExamState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateExamCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCustomText.generate(
          text: "Number of Questions",
          textStyle: AppTextStyles.h6SemiBold.copyWith(
            color: AppColors.colorPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              child: _NumberField(
                label: "Multiple Choice",
                initialValue: state.numMultipleChoice,
                onChanged: (v) => cubit.changeQuestionNumbers(multiple: v),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _NumberField(
                label: "True/False",
                initialValue: state.numTrueFalse,
                onChanged: (v) => cubit.changeQuestionNumbers(tf: v),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _NumberField(
                label: "Q&A",
                initialValue: state.numQA,
                onChanged: (v) => cubit.changeQuestionNumbers(qa: v),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final String initialValue;
  final Function(String) onChanged;

  const _NumberField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      style: AppTextStyles.bodySmallMedium,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: label,
        labelText: label,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: BorderSide(color: AppColors.colorPrimary, width: 1.5),
        ),
      ),
    );
  }
}
