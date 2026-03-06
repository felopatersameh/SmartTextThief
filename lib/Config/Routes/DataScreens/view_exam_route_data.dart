import 'package:smart_text_thief/Features/Exams/shared/Models/exam_model.dart';

class ViewExamRouteData {
  ViewExamRouteData({
    required this.exam,
    required this.isEditMode,
    required this.nameSubject,
    required this.idSubject,
    this.isTeacherView = false,
  });

  final ExamModel exam;
  final bool isEditMode;
  final String nameSubject;
  final String idSubject;
  final bool isTeacherView;
}

