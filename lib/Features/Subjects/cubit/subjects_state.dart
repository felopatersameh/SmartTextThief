part of 'subjects_cubit.dart';

class SubjectState extends Equatable {
  final bool? loading;
  final bool? loadinExams;
  final List<SubjectModel> listDataOfSubjects;
  final List<ExamModel> listDataOfExams;
  final String? error;  
  const SubjectState({
    this.loading,
    this.loadinExams,
    this.listDataOfSubjects = const [],
    this.listDataOfExams = const [],
    this.error,
  });

  @override
  List<Object?> get props => [loading, loadinExams, listDataOfSubjects, listDataOfExams, error];

  SubjectState copyWith({
    bool? loading,
    bool? loadinExams,
    List<SubjectModel>? listDataOfSubjects,
    List<ExamModel>? listDataOfExams,
    String? error,
  }) {
    return SubjectState(
      loading: loading ?? this.loading,
      loadinExams: loadinExams ?? this.loadinExams,
      listDataOfSubjects: listDataOfSubjects ?? this.listDataOfSubjects,
      listDataOfExams: listDataOfExams ?? this.listDataOfExams,
      error: error ?? this.error,
    );
  }
}
