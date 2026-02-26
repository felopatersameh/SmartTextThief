import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Config/setting.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/Models/questions_generated_model.dart';
import 'package:smart_text_thief/Core/Utils/show_message_snack_bar.dart';
import 'package:smart_text_thief/Features/ViewExam/data/repositories/view_exam_repository.dart';

part 'teacher_result_state.dart';

class TeacherResultCubit extends Cubit<TeacherResultState> {
  TeacherResultCubit({
    required ExamModel exam,
    required bool isEditMode,
    required String nameSubject,
    ViewExamRepository? repository,
  })  : _repository = repository ?? ViewExamRepository(),
        super(
          TeacherResultState(
            exam: exam,
            isEditMode: isEditMode,
            startDate: exam.startedAt,
            endDate: exam.examFinishAt,
            nameSubject: nameSubject,
          ),
        );

  final ViewExamRepository _repository;

  void updateQuestion(int index, QuestionsGeneratedModel updatedQuestion) {
    final updatedQuestions = List<QuestionsGeneratedModel>.from(
      state.exam.questions,
    );
    updatedQuestions[index] = updatedQuestion;

    final updatedExam = state.exam.copyWith(
      questions: updatedQuestions,
      questionCount: updatedQuestions.length,
    );
    emit(state.copyWith(exam: updatedExam));
  }

  void deleteQuestion(int index) {
    final updatedQuestions = List<QuestionsGeneratedModel>.from(
      state.exam.questions,
    );
    updatedQuestions.removeAt(index);

    final updatedExam = state.exam.copyWith(
      questions: updatedQuestions,
      questionCount: updatedQuestions.length,
    );
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
    if (studentEmail == state.selectedStudentEmail) {
      emit(state.copyWith(selectedStudentEmail: ''));
      return;
    }
    emit(state.copyWith(selectedStudentEmail: studentEmail));
  }

  Future<void> saveSubmit(BuildContext context) async {
    final model = state.exam;
    emit(state.copyWith(loadingSave: true));
    final response = await _repository.saveExam(model, state.nameSubject);
    await response.fold(
      (error) async {
        await showMessageSnackBar(
          context,
          title: ViewExamStrings.errorSaving,
          type: MessageType.error,
        );
      },
      (done) async {
        await showMessageSnackBar(
          context,
          title: ViewExamStrings.uploaded,
          type: MessageType.success,
        );
        if (!context.mounted) return;
        AppRouter.pushToMainScreen(context);
      },
    );
    emit(state.copyWith(loadingSave: false));
  }
}
