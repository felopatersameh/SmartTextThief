import 'firebase_service.dart';
import '../../Utils/Enums/data_key.dart';
import '../../Utils/Models/exam_exam_result.dart';
import '../../Utils/Models/exam_model.dart';
import '../../Utils/Models/data_model.dart';
import '../../Utils/Enums/collection_key.dart';

class AnalysisData {
  static Future<List<DataModel>> analyzedInstructor({
    required String email,
  }) async {
    final object = "${DataKey.subjectTeacher.key}.${DataKey.teacherEmail.key}";

    try {
      // جلب جميع المواد في استعلام واحد
      final subjectsResponse = await FirebaseServices.instance.firestore!
          .collection(CollectionKey.subjects.key)
          .where(object, isEqualTo: email)
          .get();

      final int countDoc = subjectsResponse.docs.length;
      if (countDoc == 0) {
        return _getDefaultInstructorData();
      }

      // جلب جميع الامتحانات بشكل متوازي
      final examFutures = subjectsResponse.docs.map((subjectDoc) {
        final String idSubject = subjectDoc[DataKey.subjectIdSubject.key];
        return FirebaseServices.instance.firestore!
            .collection(CollectionKey.subjects.key)
            .doc(idSubject)
            .collection(CollectionKey.exams.key)
            .get();
      }).toList();

      final allExamsResults = await Future.wait(examFutures);

      int countExam = 0;
      int endedExam = 0;
      int runningExam = 0;

      // معالجة البيانات بشكل متوازي
      final examProcessingFutures = allExamsResults
          .expand((examQuery) => examQuery.docs)
          .map((examDoc) async {
        final model = ExamModel.fromJson(examDoc.data());
        return model;
      }).toList();

      final allExams = await Future.wait(examProcessingFutures);

      for (final exam in allExams) {
        countExam++;
        if (exam.isEnded) {
          endedExam++;
        } else {
          runningExam++;
        }
      }

      return [
        DataModel(name: "Exams Created", valueNum: countExam),
        DataModel(name: "Subjects Created", valueNum: countDoc),
        DataModel(name: "Ended Exams", valueNum: endedExam),
        DataModel(name: "Running Exams", valueNum: runningExam),
      ];
    } catch (e) {
      // debugPrint('Error in analyzedInstructor: $e');
      return _getDefaultInstructorData();
    }
  }

  static Future<List<DataModel>> analyzedStudent({
    required String email,
  }) async {
    try {
      // جلب جميع المواد في استعلام واحد
      final subjectsResponse = await FirebaseServices.instance.firestore!
          .collection(CollectionKey.subjects.key)
          .where(DataKey.subjectEmailSts.key, arrayContains: email)
          .get();

      final int countDoc = subjectsResponse.docs.length;
      if (countDoc == 0) {
        return _getDefaultStudentData();
      }

      // جلب جميع الامتحانات بشكل متوازي
      final examFutures = subjectsResponse.docs.map((subjectDoc) {
        final String idSubject = subjectDoc[DataKey.subjectIdSubject.key];
        return FirebaseServices.instance.firestore!
            .collection(CollectionKey.subjects.key)
            .doc(idSubject)
            .collection(CollectionKey.exams.key)
            .get();
      }).toList();

      final allExamsResults = await Future.wait(examFutures);

      int countExam = 0;
      final List<num> degree = [];
      final List<num> realDegree = [];

      // معالجة جميع الامتحانات بشكل متوازي
      final processingFutures = allExamsResults
          .expand((examQuery) => examQuery.docs)
          .map((examDoc) async {
        final model = ExamModel.fromJson(examDoc.data());
        final exam = model.examResult.firstWhere(
          (test) => test.examResultEmailSt == email,
          orElse: () => ExamResultModel.noLabel,
        );

        if (exam != ExamResultModel.noLabel) {
          countExam++;
          if (model.isEnded) {
            degree.add(int.tryParse(exam.examResultDegree) ?? 0);
            realDegree.add(exam.numberOfQuestions);
          }
        }
        return {'exam': exam, 'model': model};
      }).toList();

      await Future.wait(processingFutures);

      // حساب GPA والمستوى
      final degrees = calculateGpaWithLevel(degree, realDegree);
      final double gpa = degrees["gpa"];
      final String level = degrees["level"];
      final int totalDegree =
          degree.fold<int>(0, (prev, e) => prev + (e as int));
      final int totalRealDegree =
          realDegree.fold<int>(0, (prev, e) => prev + (e as int));

      return [
        DataModel(name: "Done Exams", valueNum: countExam),
        DataModel(name: "GPA", valueNum: gpa),
        DataModel(name: "Level Student", valueNum: -1, valueString: level),
        DataModel(
          name: "From $totalRealDegree",
          valueNum: -1,
          valueString: "$totalDegree",
        ),
      ];
    } catch (e) {
      // debugPrint('Error in analyzedStudent: $e');
      return _getDefaultStudentData();
    }
  }

  // دوال مساعدة للبيانات الافتراضية
  static List<DataModel> _getDefaultInstructorData() {
    return [
      DataModel(name: "Exams Created", valueNum: 0),
      DataModel(name: "Subjects Created", valueNum: 0),
      DataModel(name: "Ended Exams", valueNum: 0),
      DataModel(name: "Running Exams", valueNum: 0),
    ];
  }

  static List<DataModel> _getDefaultStudentData() {
    return [
      DataModel(name: "Done Exams", valueNum: 0),
      DataModel(name: "GPA", valueNum: 0.0),
      DataModel(name: "Level Student", valueNum: -1, valueString: "none"),
      DataModel(name: "From 0", valueNum: -1, valueString: "0"),
    ];
  }

  // دالة محسنة لحساب GPA والمستوى
  static Map<String, dynamic> calculateGpaWithLevel(
      List<num> degrees, List<num> realDegrees) {
    if (degrees.isEmpty || realDegrees.isEmpty) {
      return {"gpa": 0.0, "level": "none"};
    }

    double totalScore = 0.0;
    double totalMaxScore = 0.0;

    for (int i = 0; i < degrees.length; i++) {
      totalScore += degrees[i].toDouble();
      totalMaxScore += realDegrees[i].toDouble();
    }

    final double percentage = (totalScore / totalMaxScore) * 100;
    final double gpa = (percentage / 100) * 4.0;

    String level;
    if (percentage >= 90) {
      level = "Excellent";
    } else if (percentage >= 80) {
      level = "Very Good";
    } else if (percentage >= 70) {
      level = "Good";
    } else if (percentage >= 60) {
      level = "Pass";
    } else {
      level = "Fail";
    }

    return {"gpa": double.parse(gpa.toStringAsFixed(2)), "level": level};
  }
}
