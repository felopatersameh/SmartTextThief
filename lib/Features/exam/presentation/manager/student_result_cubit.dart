import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Features/exam/data/models/exam_model.dart';
import 'package:smart_text_thief/Features/exam/data/models/exam_result_model.dart';
import 'package:smart_text_thief/Features/exam/data/repositories/view_exam_repository.dart';

part 'student_result_state.dart';

class StudentResultCubit extends Cubit<StudentResultState> {
  StudentResultCubit({
    required ExamModel exam,
    required String idSubject,
    ViewExamRepository? repository,
  })  : _repository = repository ?? ViewExamRepository(),
        super(StudentResultState(exam: exam, idSubject: idSubject));

  final ViewExamRepository _repository;

  Future<void> init() async {
    if (state.exam.isTeacher) return;
    if (!state.exam.doExam && !state.exam.showResult) return;

    emit(state.copyWith(loading: true, error: null));
    final response = await _repository.getResult(
      idSubject: state.idSubject,
      idExam: state.exam.id,
    );

    response.fold(
      (error) => emit(
        state.copyWith(
          loading: false,
          error: error,
        ),
      ),
      (resultResponse) {
        final firstFromList =
            (resultResponse.dataList != null && resultResponse.dataList!.isNotEmpty)
                ? resultResponse.dataList!.first
                : null;
        final ExamResultModel? studentResult =
            resultResponse.data ?? firstFromList;

        emit(
          state.copyWith(
            loading: false,
            error: null,
            result: studentResult,
          ),
        );
      },
    );
  }
}

