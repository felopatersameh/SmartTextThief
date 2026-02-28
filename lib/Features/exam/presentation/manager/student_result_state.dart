part of 'student_result_cubit.dart';

class StudentResultState extends Equatable {
  const StudentResultState({
    required this.exam,
    required this.idSubject,
    this.result,
    this.loading = false,
    this.error,
  });

  final ExamModel exam;
  final String idSubject;
  final ExamResultModel? result;
  final bool loading;
  final String? error;

  StudentResultState copyWith({
    ExamModel? exam,
    String? idSubject,
    Object? result = _resultNotChanged,
    bool? loading,
    Object? error = _errorNotChanged,
  }) {
    return StudentResultState(
      exam: exam ?? this.exam,
      idSubject: idSubject ?? this.idSubject,
      result: result == _resultNotChanged ? this.result : result as ExamResultModel?,
      loading: loading ?? this.loading,
      error: error == _errorNotChanged ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [exam, idSubject, result, loading, error];
}

const _resultNotChanged = Object();
const _errorNotChanged = Object();
