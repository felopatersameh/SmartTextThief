import 'dart:async';
import 'dart:convert';

import 'package:smart_text_thief/Config/env_config.dart';
import 'package:smart_text_thief/Core/LocalStorage/local_storage_service.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Services/Gemini/api_gemini.dart';
import 'package:smart_text_thief/Core/Utils/Enums/data_key.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';

class DoExamRemoteDataSource {
  static const String _liveExamStoragePrefix = 'live_exam_';
  static final Map<String, Map<String, dynamic>> _liveExamCache =
      <String, Map<String, dynamic>>{};
  static final Map<String, StreamController<Map<String, dynamic>>>
      _liveExamControllers = <String, StreamController<Map<String, dynamic>>>{};
  static final Map<String, StreamSubscription<Map<String, dynamic>>>
      _listenerSubscriptions =
      <String, StreamSubscription<Map<String, dynamic>>>{};
  static final Map<String, String> _listenerExamIds = <String, String>{};
  static int _listenerCounter = 0;

  Future<bool> hasStudentSubmitted(ExamModel model) async {
    return model.doExam;
  }

  Future<void> createLiveExam(ExamModel model) async {
    final liveExamId = model.specialIdLiveExam;
    final payload = _buildInitialPayload(model);
    await _persistLiveExamPayload(liveExamId, payload);
  }

  String listenLiveExam(
    ExamModel model,
    void Function(dynamic data, String? key) onData, {
    void Function(dynamic error)? onError,
  }) {
    final liveExamId = model.specialIdLiveExam;
    final listenerId = 'live_exam_listener_${++_listenerCounter}';

    unawaited(_emitInitialSnapshot(liveExamId, onData));

    final subscription = _controllerFor(liveExamId).stream.listen(
      (payload) {
        onData(Map<String, dynamic>.from(payload), null);
      },
      onError: onError,
    );

    _listenerSubscriptions[listenerId] = subscription;
    _listenerExamIds[listenerId] = liveExamId;
    return listenerId;
  }

  Future<void> unListenLiveExam(String listenerId) async {
    final subscription = _listenerSubscriptions.remove(listenerId);
    _listenerExamIds.remove(listenerId);
    await subscription?.cancel();
  }

  Future<void> updateLiveExamTimer(ExamModel model, int timerExam) async {
    final liveExamId = model.specialIdLiveExam;
    final payload = await _ensureLiveExamPayload(model);
    payload[AppConstants.liveExamTimeKey] = timerExam;
    payload[AppConstants.liveExamDisposeKey] = 0;
    await _persistLiveExamPayload(liveExamId, payload);
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

    final liveExamId = model.specialIdLiveExam;
    final payload = await _ensureLiveExamPayload(model);
    final questionData = _asMutableMap(payload[questionId]);
    questionData['studentAnswer'] = answer;
    payload[questionId] = questionData;

    await _persistLiveExamPayload(liveExamId, payload);
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

    return true;
  }

  Future<void> deleteLiveExam(ExamModel model) async {
    final liveExamId = model.specialIdLiveExam;
    _liveExamCache.remove(liveExamId);

    final listenersForExam = _listenerExamIds.entries
        .where((entry) => entry.value == liveExamId)
        .map((entry) => entry.key)
        .toList(growable: false);

    for (final listenerId in listenersForExam) {
      await unListenLiveExam(listenerId);
    }

    final controller = _liveExamControllers.remove(liveExamId);
    await controller?.close();

    await LocalStorageService.removeValue(_storageKey(liveExamId));
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
4. If the answer is clearly wrong, contradictory, or irrelevant -> return false.
5. If the answer captures the main concept even with different phrasing -> return true.
6. If the answer is too vague or missing the main idea -> return false.
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

  Map<String, dynamic> _buildInitialPayload(ExamModel model) {
    final payload = <String, dynamic>{
      AppConstants.liveExamStartTimeKey: DateTime.now().millisecondsSinceEpoch,
      AppConstants.liveExamTimeKey: 0,
      AppConstants.liveExamDisposeKey: 0,
    };

    for (final element in model.examStatic.examResultQA) {
      payload[element.questionId] = element.toJson();
    }
    return payload;
  }

  Future<Map<String, dynamic>> _ensureLiveExamPayload(ExamModel model) async {
    final liveExamId = model.specialIdLiveExam;
    final cached = _liveExamCache[liveExamId];
    if (cached != null && cached.isNotEmpty) {
      return Map<String, dynamic>.from(cached);
    }

    final stored = await _loadStoredPayload(liveExamId);
    if (stored.isNotEmpty) {
      _liveExamCache[liveExamId] = stored;
      return Map<String, dynamic>.from(stored);
    }

    final created = _buildInitialPayload(model);
    _liveExamCache[liveExamId] = created;
    return Map<String, dynamic>.from(created);
  }

  Future<void> _emitInitialSnapshot(
    String liveExamId,
    void Function(dynamic data, String? key) onData,
  ) async {
    final cached = _liveExamCache[liveExamId];
    if (cached != null && cached.isNotEmpty) {
      onData(Map<String, dynamic>.from(cached), null);
      return;
    }

    final stored = await _loadStoredPayload(liveExamId);
    if (stored.isNotEmpty) {
      _liveExamCache[liveExamId] = stored;
      onData(Map<String, dynamic>.from(stored), null);
    }
  }

  Future<void> _persistLiveExamPayload(
    String liveExamId,
    Map<String, dynamic> payload,
  ) async {
    final normalized = Map<String, dynamic>.from(payload);
    _liveExamCache[liveExamId] = normalized;
    await LocalStorageService.setValue(
      _storageKey(liveExamId),
      jsonEncode(normalized),
    );

    final controller = _liveExamControllers[liveExamId];
    if (controller != null && !controller.isClosed) {
      controller.add(Map<String, dynamic>.from(normalized));
    }
  }

  Future<Map<String, dynamic>> _loadStoredPayload(String liveExamId) async {
    final raw = LocalStorageService.getValue(
      _storageKey(liveExamId),
      defaultValue: null,
    );
    if (raw == null) return <String, dynamic>{};

    if (raw is Map<String, dynamic>) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return <String, dynamic>{};
      }
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _asMutableMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return Map<String, dynamic>.from(raw);
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  StreamController<Map<String, dynamic>> _controllerFor(String liveExamId) {
    final existing = _liveExamControllers[liveExamId];
    if (existing != null && !existing.isClosed) {
      return existing;
    }
    final controller = StreamController<Map<String, dynamic>>.broadcast();
    _liveExamControllers[liveExamId] = controller;
    return controller;
  }

  String _storageKey(String liveExamId) => '$_liveExamStoragePrefix$liveExamId';
}
