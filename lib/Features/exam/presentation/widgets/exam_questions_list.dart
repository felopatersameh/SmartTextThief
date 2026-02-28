import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Features/exam/presentation/widgets/exam_question_view_model.dart';
import 'package:smart_text_thief/Features/exam/domain/enums/exam_mode.dart';
import 'package:smart_text_thief/Features/exam/presentation/widgets/exam_question_card.dart';

class ExamQuestionsList extends StatelessWidget {
  const ExamQuestionsList({
    super.key,
    required this.questions,
    required this.mode,
    this.allowQuestionEditing = false,
    this.solvingAnswers = const {},
    this.onQuestionUpdated,
    this.onQuestionDeleted,
    this.onAnswerChanged,
  });

  final List<ExamQuestionViewModel> questions;
  final ExamMode mode;
  final bool allowQuestionEditing;
  final Map<String, String> solvingAnswers;
  final void Function(int index, ExamQuestionViewModel question)? onQuestionUpdated;
  final void Function(int index)? onQuestionDeleted;
  final void Function(String questionId, String answer)? onAnswerChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: questions.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final question = questions[index];

        return ExamQuestionCard(
          index: index,
          question: question,
          mode: mode,
          currentAnswer: solvingAnswers[question.id],
          allowQuestionEditing: allowQuestionEditing,
          onDelete: onQuestionDeleted == null ? null : () => onQuestionDeleted!(index),
          onQuestionChanged: (value) {
            if (onQuestionUpdated == null) return;
            onQuestionUpdated!(
              index,
              question.copyWith(text: value),
            );
          },
          onCorrectAnswerChanged: (value) {
            if (onQuestionUpdated == null) return;
            onQuestionUpdated!(
              index,
              question.copyWith(correctAnswer: value),
            );
          },
          onAnswerChanged: (value) {
            if (onAnswerChanged == null) return;
            onAnswerChanged!(question.id, value);
          },
        );
      },
    );
  }
}

