import 'package:smart_text_thief/Core/LocalStorage/get_local_storage.dart';
import 'package:smart_text_thief/Core/Services/Firebase/firebase_service.dart';
import 'package:smart_text_thief/Core/Services/Firebase/real_time_firbase.dart';
import 'package:smart_text_thief/Core/Services/Notifications/notification_model.dart';
import 'package:smart_text_thief/Core/Services/Notifications/notification_services.dart';
import 'package:smart_text_thief/Core/Utils/Enums/collection_key.dart';
import 'package:smart_text_thief/Core/Utils/Enums/data_key.dart';
import 'package:smart_text_thief/Core/Utils/Enums/notification_type.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_exam_result.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_result_q_a.dart';

class DoExamRemoteDataSource {
  Future<void> createLiveExam(ExamModel model) async {
    final map = <String, dynamic>{};
    final otherMap = <String, dynamic>{
      'start_time': DateTime.now().millisecondsSinceEpoch,
      'time': 0,
      'dispose_exam': 0,
    };
    for (final element in model.examStatic.examResultQA) {
      map[element.questionId] = element.toJson();
    }
    await RealtimeFirebase.create(
      'Exam_Live',
      map,
      otherData: otherMap,
      id: model.specialIdLiveExam,
    );
  }

  String listenLiveExam(
    ExamModel model,
    void Function(dynamic data, String? key) onData, {
    void Function(dynamic error)? onError,
  }) {
    return RealtimeFirebase.listen(
      'Exam_Live/${model.specialIdLiveExam}',
      (data, key) {
        onData(data, key);
        return null;
      },
      onError: onError,
    );
  }

  Future<void> unListenLiveExam(String listenerId) {
    return RealtimeFirebase.unListen(listenerId);
  }

  Future<void> updateLiveExamTimer(ExamModel model, int timerExam) async {
    final timerUpdate = <String, dynamic>{
      'time': timerExam,
      'dispose_exam': 0,
    };
    await RealtimeFirebase.updateData(
      'Exam_Live/${model.specialIdLiveExam}',
      {},
      otherUpdates: timerUpdate,
    );
  }

  Future<void> updateAnswer({
    required ExamModel model,
    required String questionId,
    required String answer,
  }) async {
    final questionIndex = model.examStatic.examResultQA.indexWhere(
      (q) => q.questionId == questionId,
    );
    if (questionIndex == -1) return;

    final question = model.examStatic.examResultQA[questionIndex];
    final updatedQuestion = question.copyWith(studentAnswer: answer);
    final updateData = {questionId: updatedQuestion.toJson()};
    await RealtimeFirebase.updateData(
      'Exam_Live/${model.specialIdLiveExam}',
      updateData,
    );
  }

  Future<void> submitExam({
    required ExamModel model,
    required Map<String, String> userAnswers,
  }) async {
    final resultsUpdate = <String, dynamic>{};
    var totalScore = 0;

    for (final question in model.examStatic.examResultQA) {
      final studentAnswer = userAnswers[question.questionId] ?? '';
      final isCorrect = studentAnswer == question.correctAnswer;
      final score = isCorrect ? 1 : 0;
      totalScore += score;
      resultsUpdate[question.questionId] = {
        ...question.toJson(),
        'studentAnswer': studentAnswer,
        'score': score,
        'evaluated': true,
      };
    }

    final emailStudent = GetLocalStorage.getEmailUser();
    final examResultQA = resultsUpdate.values
        .map((e) => ExamResultQA.fromJson(e as Map<String, dynamic>))
        .toList();
    final currentResult = ExamResultModel(
      examResultEmailSt: emailStudent,
      examResultDegree: totalScore.toString(),
      examResultQA: examResultQA,
      levelExam: model.examStatic.levelExam,
      numberOfQuestions: model.examStatic.numberOfQuestions,
      typeExam: model.examStatic.typeExam,
    );

    final latestExamResponse = await FirebaseServices.instance.getData(
      model.examIdSubject,
      CollectionKey.subjects.key,
      subCollections: [CollectionKey.exams.key],
      subIds: [model.examId],
    );

    final mergedResults = <Map<String, dynamic>>[];
    if (latestExamResponse.status && latestExamResponse.data is Map) {
      final latestExamData =
          Map<String, dynamic>.from(latestExamResponse.data as Map);
      final latestResults = latestExamData[DataKey.examExamResult.key];
      if (latestResults is List) {
        for (final result in latestResults) {
          Map<String, dynamic>? resultMap;
          if (result is Map<String, dynamic>) {
            resultMap = result;
          } else if (result is Map) {
            resultMap = Map<String, dynamic>.from(result);
          }
          if (resultMap == null) continue;
          if (resultMap[DataKey.examResultEmailSt.key] == emailStudent) {
            continue;
          }
          mergedResults.add(resultMap);
        }
      }
    }
    mergedResults.add(currentResult.toJson());

    await FirebaseServices.instance.updateData(
      CollectionKey.subjects.key,
      model.examIdSubject,
      {
        DataKey.examExamResult.key: mergedResults,
      },
      subCollections: [CollectionKey.exams.key],
      subIds: [model.examId],
    );
  }

  Future<void> deleteLiveExam(ExamModel model) {
    return RealtimeFirebase.deleteData('Exam_Live/${model.specialIdLiveExam}');
  }

  Future<void> notifySubmitted(ExamModel model) async {
    final nameParts = GetLocalStorage.getNameUser().split(' ');
    final name = nameParts.length >= 2
        ? '${nameParts[0]} ${nameParts[1]}'
        : GetLocalStorage.getNameUser();
    final length = model.examResult.isEmpty || model.examResult.length - 1 == 0;
    final and = length ? '' : 'and ${model.examResult.length} members';
    final notification = NotificationModel(
      id: 'doExam_${model.examId}',
      topicId: '${model.examIdSubject}_admin',
      type: NotificationType.submit,
      body:
          '$name Submitted Exam ${model.examStatic.typeExam} ${model.specialIdLiveExam} $and',
    );
    await NotificationServices.sendNotificationToTopic(
      id: notification.id,
      data: notification.toJson(),
      stringData: notification.toJsonString(),
    );
  }
}
