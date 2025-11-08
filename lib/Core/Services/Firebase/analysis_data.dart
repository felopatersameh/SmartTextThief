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
    final object =
        "${(DataKey.subjectTeacher.key)}.${(DataKey.teacherEmail.key)}";
    int countDoc = 0;
    int countExam = 0;
    int endedExam = 0;
    int runningExam = 0;
    final response = await FirebaseServices.instance.firestore!
        .collection(CollectionKey.subjects.key)
        .where(object, isEqualTo: email)
        .get();
    countDoc = response.docs.length;
    if (countDoc != 0) {
      for (var element in response.docs) {
        final String idSubject = element[DataKey.subjectIdSubject.key];
        final responseExam = await FirebaseServices.instance.firestore!
            .collection(CollectionKey.subjects.key)
            .doc(idSubject)
            .collection(CollectionKey.exams.key)
            .get();
        countExam += responseExam.docs.length;
        if (countExam != 0) {
          for (var element in responseExam.docs) {
            final idExam = element[DataKey.examId.key];
            final result = await FirebaseServices.instance.firestore!
                .collection(CollectionKey.subjects.key)
                .doc(idSubject)
                .collection(CollectionKey.exams.key)
                .doc(idExam)
                .get();
            final model = ExamModel.fromJson(
              result.data() as Map<String, dynamic>,
            );
            if (model.isEnded) {
              ++endedExam;
            } else {
              ++runningExam;
            }
          }
        }
      }
    }
    return [
      DataModel(name: "Exams Created", valueNum: countExam.toInt()),
      DataModel(name: "Subjects Created", valueNum: countDoc.toInt()),
      DataModel(name: "Ended Exams", valueNum: endedExam.toInt()),
      DataModel(name: "Running Exams", valueNum: runningExam.toInt()),
    ];
  }

  static Future<List<DataModel>> analyzedStudent({
    required String email,
  }) async {
    int countDoc = 0;
    int countExam = 0;
    String level = "none";
    double gpa = 0.0;
    final List<num> degree = [];
    final List<num> realDegree = [];

    final response = await FirebaseServices.instance.firestore!
        .collection(CollectionKey.subjects.key)
        .where(DataKey.subjectEmailSts.key, arrayContains: email)
        .get();
    countDoc = response.docs.length;
    if (countDoc != 0) {
      for (var element in response.docs) {
        final String id = element[DataKey.subjectIdSubject.key];
        final responseExam = await FirebaseServices.instance.firestore!
            .collection(CollectionKey.subjects.key)
            .doc(id)
            .collection(CollectionKey.exams.key)
            .get();
        for (var element in responseExam.docChanges) {
          final model = ExamModel.fromJson(
            element.doc.data() as Map<String, dynamic>,
          );
          final exam = model.examResult.firstWhere((test) {
            if (test.examResultEmailSt == email) return true;
            return false;
          }, orElse: () => ExamResultModel.noLabel);
          if (exam != ExamResultModel.noLabel) {
            ++countExam;
            if (model.isEnded) {
              degree.add(int.tryParse(exam.examResultDegree) ?? 0);
              realDegree.add(exam.numberOfQuestions);
            }
          } else {
            degree.add(0);
            realDegree.add(exam.numberOfQuestions);
          }
        }
        final degrees = calculateGpaWithLevel(degree, realDegree);
        gpa = degrees["gpa"];
        level = degrees["level"];
      }
    }
    return [
      DataModel(name: "Done Exams", valueNum: countExam.toInt()),
      DataModel(name: "GPA", valueNum: gpa),
      DataModel(name: "Level Student", valueNum: -1, valueString: level),
      DataModel(
        name: "From ${realDegree.fold<int>(0, (prev, e) => prev + (e as int))}",
        valueNum: -1,
        valueString: "${degree.fold<int>(0, (prev, e) => prev + (e as int))}",
      ),
    ];
  }
}
