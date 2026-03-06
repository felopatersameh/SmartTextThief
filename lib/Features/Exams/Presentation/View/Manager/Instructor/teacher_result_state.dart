part of 'teacher_result_cubit.dart';

class TeacherResultState extends Equatable {
  const TeacherResultState({
    required this.exam,
    required this.isEditMode,
    required this.idSubject,
    this.loadingSave = false,
    this.loadingResults = false,
    this.selectedStudentEmail,
    this.startDate,
    this.endDate,
    required this.nameSubject,
    this.examResults = const [],
    this.error,
  });

  final ExamModel exam;
  final bool isEditMode;
  final String idSubject;
  final bool loadingSave;
  final bool loadingResults;
  final String? selectedStudentEmail;
  final DateTime? startDate;
  final DateTime? endDate;
  final String nameSubject;
  final List<ExamResultModel> examResults;
  final String? error;

  TeacherResultState copyWith({
    ExamModel? exam,
    bool? isEditMode,
    String? idSubject,
    bool? loadingSave,
    bool? loadingResults,
    Object? selectedStudentEmail = _selectedStudentEmailNotChanged,
    DateTime? startDate,
    DateTime? endDate,
    String? nameSubject,
    List<ExamResultModel>? examResults,
    Object? error = _errorNotChanged,
  }) {
    return TeacherResultState(
      exam: exam ?? this.exam,
      isEditMode: isEditMode ?? this.isEditMode,
      idSubject: idSubject ?? this.idSubject,
      loadingSave: loadingSave ?? this.loadingSave,
      loadingResults: loadingResults ?? this.loadingResults,
      selectedStudentEmail: selectedStudentEmail == _selectedStudentEmailNotChanged
          ? this.selectedStudentEmail
          : selectedStudentEmail as String?,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nameSubject: nameSubject ?? this.nameSubject,
      examResults: examResults ?? this.examResults,
      error: error == _errorNotChanged ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [
        exam,
        isEditMode,
        idSubject,
        loadingSave,
        loadingResults,
        selectedStudentEmail,
        startDate,
        endDate,
        nameSubject,
        examResults,
        error,
      ];
}

const _selectedStudentEmailNotChanged = Object();
const _errorNotChanged = Object();
