import 'dart:convert';

import 'package:smart_text_thief/Config/env_config.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Services/Firebase/real_time_firbase.dart';
import 'package:smart_text_thief/Core/Services/Gemini/api_gemini.dart';
import 'package:smart_text_thief/Core/Utils/Enums/data_key.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';

class DoExamRemoteDataSource {
  Future<bool> hasStudentSubmitted(ExamModel model) async {
    return model.doExam;
  }

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

  Future<bool> submitExam({
    required ExamModel model,
    required Map<String, String> userAnswers,
  }) async {
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
      if (score < 0) {
        return false;
      }
    }

    // Firestore submit endpoint was removed. Keep success behavior to finish exam flow.
    return true;
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

    final apiKey = await _resolveGeminiApiKey();
    if (apiKey.isEmpty) return {};

    final modelName = model.examStatic.geminiModel.trim().isEmpty
        ? AppConstants.defaultGeminiModel
        : model.examStatic.geminiModel.trim();

    try {
      final api = ApiGemini(
        apiKey: apiKey,
        modelName: modelName,
        maxOutputTokens: 400,
        temperature: 0.15,
      );
      final response = await api.generateContent(
        _buildSemanticEvaluationPrompt(payload),
      );
      return _parseBooleanMap(response.text ?? '');
    } catch (_) {
      return {};
    }
  }

  Future<String> _resolveGeminiApiKey() async {
    // final localKey = LocalStorageService.getValue(
    //   LocalStorageKeys.geminiApiKey,
    //   defaultValue: '',
    // // );
    // final key = (localKey ?? '').toString().trim();
    // if (key.isNotEmpty) {
    //   return key;
    // }
    return EnvConfig.geminiFallbackApiKey;
  }

String _buildSemanticEvaluationPrompt(List<Map<String, String>> payload) {
  final payloadJson = jsonEncode(payload);

  return '''
You are grading short-answer exam responses.

Evaluation Guidelines:
1. Compare studentAnswer with correctAnswer by meaning, not exact wording.
2. Minor wording differences or synonyms are acceptable.
3. The core idea must be clearly present.
4. If the answer is clearly wrong, contradictory, or irrelevant → return false.
5. If the answer captures the main concept even with different phrasing → return true.
6. If the answer is too vague or missing the main idea → return false.
7. Do NOT use external knowledge beyond what is implied by correctAnswer.

Return ONLY a valid JSON object.
Keys = questionId
Values = true or false

Example:
{"Q1": true, "Q2": false}

Evaluate:
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

}
