import 'package:smart_text_thief/Features/exam/data/models/exam_model.dart';

class ViewExamRouteData {
  ViewExamRouteData({
    required this.exam,
    required this.isEditMode,
    required this.nameSubject,
    required this.idSubject,
  });

  final ExamModel exam;
  final bool isEditMode;
  final String nameSubject;
  final String idSubject;
}

