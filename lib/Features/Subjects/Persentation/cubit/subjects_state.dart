part of 'subjects_cubit.dart';

class SubjectState extends Equatable {
  final bool loading;
  final bool loadingExams;
  final List<SubjectModel> listDataOfSubjects;
  final List<SubjectModel>? filteredSubjects;
  final List<ExamModel> listDataOfExams;
  final String? error;
  final SubjectAction? action;

  const SubjectState({
    this.loading=false,
    this.loadingExams=false,
    this.listDataOfSubjects = const [],
    this.filteredSubjects,
    this.listDataOfExams = const [],
    this.error,
    this.action,
  });

  @override
  List<Object?> get props => [
        loading,
        loadingExams,
        listDataOfSubjects,
        filteredSubjects,
        listDataOfExams,
        error,
        action
      ];

  SubjectState copyWith({
    bool? loading,
    bool? loadingExams,
    List<SubjectModel>? listDataOfSubjects,
    List<SubjectModel>? filteredSubjects,
    List<ExamModel>? listDataOfExams,
    String? error,
    SubjectAction? action,
  }) {
    return SubjectState(
      loading: loading ?? this.loading,
      loadingExams: loadingExams ?? this.loadingExams,
      listDataOfSubjects: listDataOfSubjects ?? this.listDataOfSubjects,
      filteredSubjects: filteredSubjects ?? this.filteredSubjects,
      listDataOfExams: listDataOfExams ?? this.listDataOfExams,
      error: error ?? this.error,
      action: action ?? this.action,
    );
  }
}

enum SubjectAction {
  added,
  joined,
  removed,
  updated,
}
