import '../Api/api_endpoints.dart';
import '../Api/api_service.dart';
import '../../Utils/Models/data_model.dart';
import '../../Utils/Models/exam_model.dart';
import '../../Utils/Models/subject_model.dart';

class AnalysisData {
  static Future<List<DataModel>> analyzedInstructor({
    required String email,
  }) async {
    try {
      final subjects = await _fetchSubjects();
      if (subjects.isEmpty) return _defaultInstructorData();

      final exams = await _fetchExamsForSubjects(subjects);
      final endedExam = exams.where((exam) => exam.isEnded).length;
      final runningExam = exams.length - endedExam;

      return [
        DataModel(name: 'Exams Created', valueNum: exams.length),
        DataModel(name: 'Subjects Created', valueNum: subjects.length),
        DataModel(name: 'Ended Exams', valueNum: endedExam),
        DataModel(name: 'Running Exams', valueNum: runningExam),
      ];
    } catch (_) {
      return _defaultInstructorData();
    }
  }

  static Future<List<DataModel>> analyzedStudent({
    required String email,
  }) async {
    return _defaultStudentData();
  }

  static Future<List<SubjectModel>> _fetchSubjects() async {
    final response = await DioHelper.getData(path: ApiEndpoints.subjects,);
    final data = response.data;
    if (data is! List) return const <SubjectModel>[];

    return data.map((e) => SubjectModel.fromJson(_toMap(e))).toList();
  }

  static Future<List<ExamModel>> _fetchExamsForSubjects(
    List<SubjectModel> subjects,
  ) async {
    if (subjects.isEmpty) return const <ExamModel>[];

    final responses = await Future.wait(
      subjects.map(
        (subject) => DioHelper.getData(
          path: ApiEndpoints.subjectGetExams(subject.subjectId),
        ),
      ),
    );

    final exams = <ExamModel>[];
    for (int i = 0; i < responses.length; i++) {
      final body = _toMap(responses[i].data);
      final list = body['data'];
      if (list is! List) continue;
      final subjectId = subjects[i].subjectId;
      for (final exam in list) {
        exams.add(
          ExamModel.fromJson({
            ..._toMap(exam),
            'subjectId': subjectId,
          }),
        );
      }
    }
    return exams;
  }

  static Map<String, dynamic> _toMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  static List<DataModel> _defaultInstructorData() {
    return [
      DataModel(name: 'Exams Created', valueNum: 0),
      DataModel(name: 'Subjects Created', valueNum: 0),
      DataModel(name: 'Ended Exams', valueNum: 0),
      DataModel(name: 'Running Exams', valueNum: 0),
    ];
  }

  static List<DataModel> _defaultStudentData() {
    return [
      DataModel(name: 'Done Exams', valueNum: 0),
      DataModel(name: 'GPA', valueNum: 0.0),
      DataModel(name: 'Level Student', valueNum: -1, valueString: 'none'),
      DataModel(name: 'From 0', valueNum: -1, valueString: '0'),
    ];
  }

  static Map<String, dynamic> calculateGpaWithLevel(
    List<num> degrees,
    List<num> realDegrees,
  ) {
    if (degrees.isEmpty || realDegrees.isEmpty) {
      return {'gpa': 0.0, 'level': 'none'};
    }

    double totalScore = 0;
    double totalMaxScore = 0;

    for (int i = 0; i < degrees.length; i++) {
      totalScore += degrees[i].toDouble();
      totalMaxScore += realDegrees[i].toDouble();
    }

    final percentage = (totalScore / totalMaxScore) * 100;
    final gpa = (percentage / 100) * 4.0;

    String level;
    if (percentage >= 90) {
      level = 'Excellent';
    } else if (percentage >= 80) {
      level = 'Very Good';
    } else if (percentage >= 70) {
      level = 'Good';
    } else if (percentage >= 60) {
      level = 'Pass';
    } else {
      level = 'Fail';
    }

    return {
      'gpa': double.parse(gpa.toStringAsFixed(2)),
      'level': level,
    };
  }
}
