part of 'student_result_cubit.dart';

class StudentResultState extends Equatable {
  const StudentResultState({
    required this.exam,
  });

  final ExamModel exam;

  StudentResultState copyWith({
    ExamModel? exam,
  }) {
    return StudentResultState(
      exam: exam ?? this.exam,
    );
  }

  @override
  List<Object?> get props => [exam];
}
