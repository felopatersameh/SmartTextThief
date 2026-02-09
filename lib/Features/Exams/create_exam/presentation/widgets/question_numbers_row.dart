import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Utils/Widget/custom_text_app.dart';
import 'package:smart_text_thief/Features/Exams/create_exam/presentation/cubit/create_exam_cubit.dart';

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
          text: CreateExamStrings.numberOfQuestions,
          textStyle: AppTextStyles.h6SemiBold.copyWith(
            color: AppColors.colorPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              child: _NumberField(
                label: CreateExamStrings.multipleChoice,
                initialValue: state.numMultipleChoice,
                onChanged: (v) => cubit.changeQuestionNumbers(multiple: v),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _NumberField(
                label: CreateExamStrings.trueFalse,
                initialValue: state.numTrueFalse,
                onChanged: (v) => cubit.changeQuestionNumbers(tf: v),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _NumberField(
                label: CreateExamStrings.qa,
                initialValue: state.numQA,
                onChanged: (v) => cubit.changeQuestionNumbers(qa: v),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        AppCustomText.generate(
          text: CreateExamStrings.examDurationMin,
          textStyle: AppTextStyles.h6SemiBold.copyWith(
            color: AppColors.colorPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        _NumberField(
          label: CreateExamStrings.minOnly,
          initialValue: state.time.toString(),
          onChanged: (v) => cubit.changeTime(int.tryParse(v) ?? 0),
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
