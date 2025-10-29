import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Core/Storage/Local/get_local_storage.dart';
import '../../../../Config/setting.dart';
import '../../../../Core/Services/Firebase/firebase_service.dart';
import '../../../../Core/Utils/Enums/collection_key.dart';
import '../../../../Core/Utils/Enums/data_key.dart';
import '../../../../Core/Utils/Models/exam_exam_result.dart';
import '../../../../Core/Utils/Models/exam_model.dart';
import '../../../../Core/Utils/Models/exam_result_q_a.dart';
import '../../../../Core/Utils/show_message_snack_bar.dart';

import '../../Data/exam_source.dart';
part 'view_exam_state.dart';

class ViewExamCubit extends Cubit<ViewExamState> {
  ViewExamCubit({required ExamModel exam, required bool isEditMode})
    : super(
        ViewExamState(
          exam: exam,
          isEditMode: isEditMode,
          startDate: exam.startedAt,
          endDate: exam.examFinishAt,
        ),
      );
  Future<void> init() async {
    if (state.exam.isTeacher) return;
    if (state.isEditMode) return;
    if (!state.exam.doExam) {
      final email = GetLocalStorage.getEmailUser();
      final examResultQA = state.exam.examStatic.examResultQA;
      final updatedExamResultQA = examResultQA
          .map((element) => element.copyWith(score: "0"))
          .toList();
      final ExamResultModel lastModel = ExamResultModel(
        examResultEmailSt: email,
        examResultDegree: "0",
        examResultQA: updatedExamResultQA,
        levelExam: state.exam.examStatic.levelExam,
        numberOfQuestions: state.exam.examStatic.numberOfQuestions,
        typeExam: state.exam.examStatic.typeExam,
      );
     final response = await FirebaseServices.instance.updateData(
        CollectionKey.subjects.key,
        state.exam.examIdSubject,
        {
          DataKey.examExamResult.key: FieldValue.arrayUnion([
            lastModel.toJson(),
          ]),
        },
        subCollections: [CollectionKey.exams.key],
        subIds: [state.exam.examId],
      );
      
      if (response.status) {
         emit(
        state.copyWith(
          exam: state.exam.copyWith(
            examResult: [lastModel ,...state.exam.examResult, ],
          ),
        ),
      );
      }
     
    }
  }

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
