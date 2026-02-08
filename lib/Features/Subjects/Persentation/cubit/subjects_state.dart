part of 'subjects_cubit.dart';

class SubjectState extends Equatable {
  final bool loadingSubjects;
  final bool loadingExams;
  final List<SubjectModel> subjects;
  final List<SubjectModel> filteredSubjects;
  final List<ExamModel> exams;
  final SubjectModel? selectedSubject;
  final String searchQuery;
  final String? error;
  final SubjectAction? action;

  const SubjectState({
    this.loadingSubjects = false,
    this.loadingExams = false,
    this.subjects = const [],
    this.filteredSubjects = const [],
    this.exams = const [],
    this.selectedSubject,
    this.searchQuery = '',
    this.error,
    this.action,
  });

  @override
  List<Object?> get props => [
        loadingSubjects,
        loadingExams,
        subjects,
        filteredSubjects,
        exams,
        selectedSubject,
        searchQuery,
        error,
        action,
      ];

  List<SubjectModel> get visibleSubjects =>
      searchQuery.isEmpty ? subjects : filteredSubjects;

  SubjectState copyWith({
    bool? loadingSubjects,
    bool? loadingExams,
    List<SubjectModel>? subjects,
    List<SubjectModel>? filteredSubjects,
    List<ExamModel>? exams,
    Object? selectedSubject = _subjectNotChanged,
    String? searchQuery,
    Object? error = _errorNotChanged,
    Object? action = _actionNotChanged,
  }) {
    return SubjectState(
      loadingSubjects: loadingSubjects ?? this.loadingSubjects,
      loadingExams: loadingExams ?? this.loadingExams,
      subjects: subjects ?? this.subjects,
      filteredSubjects: filteredSubjects ?? this.filteredSubjects,
      exams: exams ?? this.exams,
      selectedSubject: selectedSubject == _subjectNotChanged
          ? this.selectedSubject
          : selectedSubject as SubjectModel?,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error == _errorNotChanged ? this.error : error as String?,
      action:
          action == _actionNotChanged ? this.action : action as SubjectAction?,
    );
  }
}

enum SubjectAction {
  added,
  joined,
  removed,
  updated,
}

const _subjectNotChanged = Object();
const _errorNotChanged = Object();
const _actionNotChanged = Object();
