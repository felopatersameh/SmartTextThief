import 'package:smart_text_thief/Core/Utils/Models/exam_exam_result.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_model.dart';

class DashboardRouteData {
  const DashboardRouteData({
    this.subject,
    this.exams = const [],
    this.results = const [],
  });

  final SubjectModel? subject;
  final List<ExamModel> exams;
  final List<ExamResultModel> results;
}

class SubjectDetailsRouteData {
  const SubjectDetailsRouteData({required this.subject});

  final SubjectModel subject;
}

class CreateExamRouteData {
  const CreateExamRouteData({required this.subject});

  final SubjectModel subject;
}

class ViewExamRouteData {
  const ViewExamRouteData({
    required this.exam,
    required this.isEditMode,
    required this.nameSubject,
  });

  final ExamModel exam;
  final bool isEditMode;
  final String nameSubject;
}

class DoExamRouteData {
  const DoExamRouteData({required this.exam});

  final ExamModel exam;
}
