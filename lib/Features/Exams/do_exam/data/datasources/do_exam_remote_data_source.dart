import 'dart:convert';

import 'package:smart_text_thief/Config/env_config.dart';
import 'package:smart_text_thief/Core/LocalStorage/get_local_storage.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Services/Firebase/firebase_service.dart';
import 'package:smart_text_thief/Core/Services/Gemini/api_gemini.dart';
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
      AppConstants.liveExamStartTimeKey: DateTime.now().millisecondsSinceEpoch,
      AppConstants.liveExamTimeKey: 0,
      AppConstants.liveExamDisposeKey: 0,
    };
    for (final element in model.examStatic.examResultQA) {
      map[element.questionId] = element.toJson();
    }
    await RealtimeFirebase.create(
      AppConstants.liveExamCollection,
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
      '${AppConstants.liveExamCollection}/${model.specialIdLiveExam}',
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
      AppConstants.liveExamTimeKey: timerExam,
      AppConstants.liveExamDisposeKey: 0,
    };
    await RealtimeFirebase.updateData(
      '${AppConstants.liveExamCollection}/${model.specialIdLiveExam}',
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
      '${AppConstants.liveExamCollection}/${model.specialIdLiveExam}',
      updateData,
    );
  }

  Future<void> submitExam({
    required ExamModel model,
    required Map<String, String> userAnswers,
  }) async {
    final resultsUpdate = <String, dynamic>{};
    var totalScore = 0;
    final shortAnswerEvaluations = await _evaluateShortAnswers(
      model: model,
      userAnswers: userAnswers,
    );

    for (final question in model.examStatic.examResultQA) {
      final studentAnswer = (userAnswers[question.questionId] ?? '').trim();
      bool isCorrect;

      if (question.questionType == AppConstants.shortAnswerType) {
        isCorrect = shortAnswerEvaluations[question.questionId] ?? false;
      } else {
        isCorrect = _isExactMatch(studentAnswer, question.correctAnswer);
      }

      final score = isCorrect ? 1 : 0;
      totalScore += score;
      resultsUpdate[question.questionId] = {
        ...question.toJson(),
        DataKey.studentAnswer.key: studentAnswer,
        DataKey.score.key: score,
        DataKey.evaluated.key: true,
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

  Future<Map<String, bool>> _evaluateShortAnswers({
    required ExamModel model,
    required Map<String, String> userAnswers,
  }) async {
    final payload = <Map<String, String>>[];
    for (final question in model.examStatic.examResultQA) {
      if (question.questionType != AppConstants.shortAnswerType) continue;
      final studentAnswer = (userAnswers[question.questionId] ?? '').trim();
      if (studentAnswer.isEmpty) continue;
      payload.add({
        DataKey.questionId.key: question.questionId,
        DataKey.questionText.key: question.questionText,
        DataKey.correctAnswer.key: question.correctAnswer,
        DataKey.studentAnswer.key: studentAnswer,
      });
    }

    if (payload.isEmpty) return {};

    final apiKey = await _resolveGeminiApiKey(model);
    if (apiKey.isEmpty) return {};

    final modelName = model.examStatic.geminiModel.trim().isEmpty
        ? AppConstants.defaultGeminiModel
        : model.examStatic.geminiModel.trim();

    try {
      final api = ApiGemini(
        apiKey: apiKey,
        modelName: modelName,
      );
      final response = await api.generateContent(
        _buildSemanticEvaluationPrompt(payload),
      );
      return _parseBooleanMap(response.text ?? '');
    } catch (_) {
      return {};
    }
  }

  Future<String> _resolveGeminiApiKey(ExamModel model) async {
    try {
      final teacherResponse = await FirebaseServices.instance.getData(
        model.examIdTeacher,
        CollectionKey.users.key,
      );
      if (teacherResponse.status && teacherResponse.data is Map) {
        final teacherData =
            Map<String, dynamic>.from(teacherResponse.data as Map);
        final teacherApiKey =
            (teacherData[DataKey.userGeminiApiKey.key] ?? '').toString().trim();
        if (teacherApiKey.isNotEmpty) {
          return teacherApiKey;
        }
      }
    } catch (_) {}

    return EnvConfig.geminiFallbackApiKey;
  }

  String _buildSemanticEvaluationPrompt(List<Map<String, String>> payload) {
    final payloadJson = jsonEncode(payload);
    return '''
You are grading short-answer exam responses.
Compare each studentAnswer against the correctAnswer by semantic meaning.

Return true when:
- The meaning is correct.
- The answer is very close to the correct meaning (minor wording differences are acceptable).

Return false when:
- The meaning is wrong, opposite, irrelevant, or incomplete in a way that changes correctness.

Return ONLY valid JSON object with questionId keys and boolean values.
Example:
{"Q1": true, "Q2": false}

Input:
$payloadJson
''';
  }

  Map<String, bool> _parseBooleanMap(String responseText) {
    if (responseText.trim().isEmpty) return {};
    try {
      final cleaned = _extractJsonObject(responseText);
      final decoded = jsonDecode(cleaned);
      if (decoded is! Map) return {};

      final result = <String, bool>{};
      for (final entry in decoded.entries) {
        final value = _toBool(entry.value);
        if (value != null) {
          result[entry.key.toString()] = value;
        }
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  String _extractJsonObject(String rawText) {
    final text = rawText.trim();
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      return text;
    }
    return text.substring(start, end + 1);
  }

  bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return null;
  }

  bool _isExactMatch(String studentAnswer, String correctAnswer) {
    return _normalizeAnswer(studentAnswer) == _normalizeAnswer(correctAnswer);
  }

  String _normalizeAnswer(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<void> deleteLiveExam(ExamModel model) {
    return RealtimeFirebase.deleteData(
      '${AppConstants.liveExamCollection}/${model.specialIdLiveExam}',
    );
  }

  Future<void> notifySubmitted(ExamModel model) async {
    final nameParts = GetLocalStorage.getNameUser().split(' ');
    final name = nameParts.length >= 2
        ? '${nameParts[0]} ${nameParts[1]}'
        : GetLocalStorage.getNameUser();
    final membersCount = model.examResult.length;
    final notification = NotificationModel(
      id: '${AppConstants.submittedExamNotificationPrefix}${model.examId}',
      topicId: '${model.examIdSubject}${AppConstants.adminTopicSuffix}',
      type: NotificationType.submit,
      body: DataSourceStrings.examSubmittedBody(
        name,
        model.examStatic.typeExam,
        model.specialIdLiveExam,
        membersCount,
      ),
    );
    await NotificationServices.sendNotificationToTopic(
      id: notification.id,
      data: notification.toJson(),
      stringData: notification.toJsonString(),
    );
  }
}
