  
part of 'view_exam_cubit.dart';

class ViewExamState extends Equatable {
  final ExamModel exam;
  final bool isEditMode;
  final bool loadingSave;
  final String? selectedStudentEmail;
  final DateTime? startDate;
  final DateTime? endDate;

  const ViewExamState({
    required this.exam,
    required this.isEditMode,
    this.loadingSave = false,
    this.selectedStudentEmail,
    this.startDate,
    this.endDate,
  });

  ViewExamState copyWith({
    ExamModel? exam,
    bool? isEditMode,
    bool? loadingSave,
    String? selectedStudentEmail,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ViewExamState(
      exam: exam ?? this.exam,
      isEditMode: isEditMode ?? this.isEditMode,
      loadingSave: loadingSave ?? this.loadingSave,
      selectedStudentEmail: selectedStudentEmail ?? this.selectedStudentEmail,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
        exam,
        isEditMode,
        loadingSave,
        selectedStudentEmail,
        startDate,
        endDate,
      ];
}

