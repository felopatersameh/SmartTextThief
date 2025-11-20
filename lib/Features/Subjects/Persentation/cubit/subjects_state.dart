part of 'subjects_cubit.dart';

class SubjectState extends Equatable {
  final bool? loading;
  final bool? loadingExams;
  final List<SubjectModel> listDataOfSubjects;
  final List<SubjectModel>? filteredSubjects;
  final List<ExamModel> listDataOfExams;
  final String? error;

  const SubjectState({
    this.loading,
    this.loadingExams,
    this.listDataOfSubjects = const [],
    this.filteredSubjects ,
    this.listDataOfExams = const [],
    this.error,
  });

  @override
  List<Object?> get props => [
        loading,
        loadingExams,
        listDataOfSubjects,
        filteredSubjects,
        listDataOfExams,
        error,
      ];

  SubjectState copyWith({
    bool? loading,
    bool? loadingExams,
    List<SubjectModel>? listDataOfSubjects,
    List<SubjectModel>? filteredSubjects,
    List<ExamModel>? listDataOfExams,
    String? error,
  }) {
    return SubjectState(
      loading: loading ?? this.loading,
      loadingExams: loadingExams ?? this.loadingExams,
      listDataOfSubjects: listDataOfSubjects ?? this.listDataOfSubjects,
      filteredSubjects: filteredSubjects ?? this.filteredSubjects,
      listDataOfExams: listDataOfExams ?? this.listDataOfExams,
      error: error ?? this.error,
    );
  }

  
}
