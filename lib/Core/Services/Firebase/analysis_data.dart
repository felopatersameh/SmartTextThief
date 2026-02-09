import '../../Utils/Enums/collection_key.dart';
import '../../Utils/Enums/data_key.dart';
import '../../Utils/Models/data_model.dart';
import '../../Utils/Models/exam_exam_result.dart';
import '../../Utils/Models/exam_model.dart';
import 'firebase_service.dart';

class AnalysisData {
  static Future<List<DataModel>> analyzedInstructor({
    required String email,
  }) async {
    try {
      final subjects = await _fetchInstructorSubjects(email);
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
    try {
      final subjects = await _fetchStudentSubjects(email);
      if (subjects.isEmpty) return _defaultStudentData();

      final exams = await _fetchExamsForSubjects(subjects);

      int doneExams = 0;
      final earnedDegrees = <num>[];
      final totalDegrees = <num>[];

      for (final examModel in exams) {
        final result = examModel.examResult.firstWhere(
          (test) => test.examResultEmailSt == email,
          orElse: () => ExamResultModel.noLabel,
        );

        if (result == ExamResultModel.noLabel) continue;

        doneExams++;
        if (!examModel.isEnded) continue;

        earnedDegrees.add(int.tryParse(result.examResultDegree) ?? 0);
        totalDegrees.add(result.numberOfQuestions);
      }

      final gpaData = calculateGpaWithLevel(earnedDegrees, totalDegrees);
      final totalDegree = earnedDegrees.fold<int>(0, (sum, e) => sum + e.toInt());
      final totalRealDegree = totalDegrees.fold<int>(0, (sum, e) => sum + e.toInt());

      return [
        DataModel(name: 'Done Exams', valueNum: doneExams),
        DataModel(name: 'GPA', valueNum: gpaData['gpa'] as double),
        DataModel(
          name: 'Level Student',
          valueNum: -1,
          valueString: gpaData['level'] as String,
        ),
        DataModel(
          name: 'From $totalRealDegree',
          valueNum: -1,
          valueString: '$totalDegree',
        ),
      ];
    } catch (_) {
      return _defaultStudentData();
    }
  }

  static Future<List<Map<String, dynamic>>> _fetchInstructorSubjects(
    String email,
  ) async {
    final object = '${DataKey.subjectTeacher.key}.${DataKey.teacherEmail.key}';
    final response = await FirebaseServices.instance.findDocsByField(
      CollectionKey.subjects.key,
      email,
      nameField: object,
    );

    if (!response.status) return const <Map<String, dynamic>>[];
    return _toMapList(response.data);
  }

  static Future<List<Map<String, dynamic>>> _fetchStudentSubjects(
    String email,
  ) async {
    final response = await FirebaseServices.instance.findDocsInList(
      CollectionKey.subjects.key,
      email,
      nameField: DataKey.subjectEmailSts.key,
    );

    if (!response.status) return const <Map<String, dynamic>>[];
    return _toMapList(response.data);
  }

  static Future<List<ExamModel>> _fetchExamsForSubjects(
    List<Map<String, dynamic>> subjects,
  ) async {
    final ids = subjects
        .map((subject) => (subject[DataKey.subjectIdSubject.key] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toList();

    if (ids.isEmpty) return const <ExamModel>[];

    final responses = await Future.wait(
      ids.map(
        (subjectId) => FirebaseServices.instance.getAllData(
          CollectionKey.subjects.key,
          subjectId,
          subCollections: [CollectionKey.exams.key],
        ),
      ),
    );

    final exams = <ExamModel>[];
    for (final response in responses) {
      if (!response.status) continue;
      for (final examMap in _toMapList(response.data)) {
        exams.add(ExamModel.fromJson(examMap));
      }
    }

    return exams;
  }

  static List<Map<String, dynamic>> _toMapList(dynamic raw) {
    if (raw is! List) return const <Map<String, dynamic>>[];

    final result = <Map<String, dynamic>>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        result.add(item);
      } else if (item is Map) {
        result.add(Map<String, dynamic>.from(item));
      }
    }
    return result;
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
