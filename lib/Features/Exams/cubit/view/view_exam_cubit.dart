import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../Config/setting.dart';
import '../../../../Core/Utils/Models/exam_model.dart';
import '../../../../Core/Utils/Models/exam_result_q_a.dart';
import '../../../../Core/Utils/show_message_snack_bar.dart';

import '../../Data/exam_source.dart';
part 'view_exam_state.dart';

class ViewExamCubit extends Cubit<ViewExamState> {
  ViewExamCubit({required ExamModel exam})
    : super(
        ViewExamState(
          exam: exam,
          isEditMode: true,
          startDate: exam.startedAt,
          endDate: exam.examFinishAt,
        ),
      );

  void toggleMode() {
    emit(state.copyWith(isEditMode: !state.isEditMode));
  }

  void updateQuestion(int index, ExamResultQA updatedQuestion) {
    final updatedQuestions = List<ExamResultQA>.from(
      state.exam.examStatic.examResultQA,
    );
    updatedQuestions[index] = updatedQuestion;

    final updatedExamStatic = state.exam.examStatic.copyWith(
      examResultQA: updatedQuestions,
    );

    final updatedExam = state.exam.copyWith(examStatic: updatedExamStatic);
    emit(state.copyWith(exam: updatedExam));
  }

  void deleteQuestion(int index) {
    final updatedQuestions = List<ExamResultQA>.from(
      state.exam.examStatic.examResultQA,
    );
    updatedQuestions.removeAt(index);

    final updatedExamStatic = state.exam.examStatic.copyWith(
      examResultQA: updatedQuestions,
      numberOfQuestions: updatedQuestions.length,
    );

    final updatedExam = state.exam.copyWith(examStatic: updatedExamStatic);
    emit(state.copyWith(exam: updatedExam));
  }

  void changeStartDate(DateTime date) {
    final updatedExam = state.exam.copyWith(startedAt: date);
    emit(state.copyWith(exam: updatedExam, startDate: date));
  }

  void changeEndDate(DateTime date) {
    final updatedExam = state.exam.copyWith(examFinishAt: date);
    emit(state.copyWith(exam: updatedExam, endDate: date));
  }

  void selectStudentResult(String studentEmail) {
    emit(state.copyWith(selectedStudentEmail: studentEmail));
  }

  Future<void> saveSubmit(BuildContext context) async {
    final model = state.exam;
    emit(state.copyWith(loadingSave: true));
    final response = await ExamSource.createExam(model.examIdSubject, model);
    response.fold(
      (error) async {
        await showMessageSnackBar(
          context,
          title: "Error to Saved... please Try Again Later",
          type: MessageType.error,
        );
      },
      (done) async {
        await showMessageSnackBar(
          context,
          title: "Uploaded",
          type: MessageType.success,
        );
        if (!context.mounted) return;
        AppRouter.nextScreenNoPath(context, NameRoutes.subject);
      },
    );
    emit(state.copyWith(loadingSave: true));
  }
}
