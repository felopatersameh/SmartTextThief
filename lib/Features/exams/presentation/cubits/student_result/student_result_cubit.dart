import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Core/LocalStorage/get_local_storage.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_result.dart';
import 'package:smart_text_thief/Features/ViewExam/data/repositories/view_exam_repository.dart';

part 'student_result_state.dart';

class StudentResultCubit extends Cubit<StudentResultState> {
  StudentResultCubit({
    required ExamModel exam,
    ViewExamRepository? repository,
  })  : _repository = repository ?? ViewExamRepository(),
        super(StudentResultState(exam: exam));

  final ViewExamRepository _repository;

  Future<void> init() async {
    if (state.exam.isTeacher) return;
    if (state.exam.doExam) return;

    final email = GetLocalStorage.getEmailUser();
    final examResultQA = state.exam.examStatic.examResultQA;
    final updatedExamResultQA =
        examResultQA.map((element) => element.copyWith(score: '0')).toList();
    final defaultResult = ExamResultModel(
      examResultEmailSt: email,
      examResultDegree: '0',
      examResultQA: updatedExamResultQA,
      levelExam: state.exam.examStatic.levelExam,
      numberOfQuestions: state.exam.examStatic.numberOfQuestions,
      typeExam: state.exam.examStatic.typeExam,
    );

    final response = await _repository.addDefaultResult(
      exam: state.exam,
      result: defaultResult,
    );

    if (response) {
      emit(
        state.copyWith(
          exam: state.exam.copyWith(
            examResult: [defaultResult, ...state.exam.examResult],
          ),
        ),
      );
    }
  }
}
