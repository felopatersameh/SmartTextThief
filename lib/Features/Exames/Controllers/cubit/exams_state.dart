part of 'exams_cubit.dart';

class SubjectState extends Equatable {
  final bool? loading;
  final List<SubjectModel> listData;
  final String? error;
  const SubjectState({this.loading, this.listData = const [], this.error});

  @override
  List<Object> get props => [?loading, listData, ?error];

  SubjectState copyWith({
    bool? loading,
    List<SubjectModel>? listData,
    String? error,
  }) {
    return SubjectState(
      loading: loading ?? this.loading,
      listData: listData ?? this.listData,
      error: error ?? this.error,
    );
  }
}
