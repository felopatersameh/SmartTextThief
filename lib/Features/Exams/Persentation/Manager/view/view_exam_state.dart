  
part of 'view_exam_cubit.dart';

class ViewExamState extends Equatable {
  final ExamModel exam;
  final bool isEditMode;
  final bool loadingSave;
  final String? selectedStudentEmail;
  final DateTime? startDate;
  final DateTime? endDate;
  final String nameSubject;

  const ViewExamState({
    required this.exam,
    required this.isEditMode,
    this.loadingSave = false,
    this.selectedStudentEmail,
    this.startDate,
    this.endDate,
  required  this.nameSubject,
  });

  ViewExamState copyWith({
    ExamModel? exam,
    bool? isEditMode,
    bool? loadingSave,
    String? selectedStudentEmail,
    DateTime? startDate,
    DateTime? endDate,
    String? nameSubject,
  }) {
    return ViewExamState(
      exam: exam ?? this.exam,
      isEditMode: isEditMode ?? this.isEditMode,
      loadingSave: loadingSave ?? this.loadingSave,
      selectedStudentEmail: selectedStudentEmail ?? this.selectedStudentEmail,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nameSubject: nameSubject ?? this.nameSubject,
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
        nameSubject,
      ];
}

