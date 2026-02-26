import 'dart:async';
import 'dart:convert';

import 'package:smart_text_thief/Core/LocalStorage/local_storage_service.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Utils/Enums/result_exam_status.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';

class DoExamRemoteDataSource {
  static const String _liveExamStoragePrefix = 'live_exam_';
  static const String _statusKey = 'result_exam_status';
  static const String _statusListKey = 'result_exam_status_list';
  static const String _statusEventsKey = 'result_exam_status_events';
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
    payload[_statusKey] = ResultExamStatus.running.value;
    _ensureStatusList(payload, const [ResultExamStatus.running]);
    _appendStatusEvent(
      payload: payload,
      status: ResultExamStatus.running,
      source: 'timer_tick',
    );
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
    required ResultExamStatus status,
    required List<ResultExamStatus> statusHistory,
    String? source,
  }) async {
    final liveExamId = model.specialIdLiveExam;
    final payload = await _ensureLiveExamPayload(model);
    for (final question in model.examStatic.examResultQA) {
      final studentAnswer = (userAnswers[question.questionId] ?? '').trim();
      final questionData = _asMutableMap(payload[question.questionId]);
      questionData['studentAnswer'] = studentAnswer;
      payload[question.questionId] = questionData;
    }

    payload[AppConstants.liveExamDisposeKey] = status == ResultExamStatus.running ? 0 : 1;
    payload[_statusKey] = status.value;
    _ensureStatusList(payload, statusHistory);
    _appendStatusEvent(
      payload: payload,
      status: status,
      source: source,
    );
    await _persistLiveExamPayload(liveExamId, payload);

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

  Map<String, dynamic> _buildInitialPayload(ExamModel model) {
    final payload = <String, dynamic>{
      AppConstants.liveExamStartTimeKey: DateTime.now().millisecondsSinceEpoch,
      AppConstants.liveExamTimeKey: 0,
      AppConstants.liveExamDisposeKey: 0,
      _statusKey: ResultExamStatus.running.value,
      _statusListKey: <String>[ResultExamStatus.running.value],
      _statusEventsKey: <Map<String, dynamic>>[
        {
          'status': ResultExamStatus.running.value,
          'source': 'init',
          'at': DateTime.now().toIso8601String(),
        },
      ],
    };

    for (final element in model.examStatic.examResultQA) {
      payload[element.questionId] = element.toJson();
    }
    return payload;
  }

  void _ensureStatusList(
    Map<String, dynamic> payload,
    List<ResultExamStatus> statusHistory,
  ) {
    payload[_statusListKey] = statusHistory.map((e) => e.value).toList(growable: false);
  }

  void _appendStatusEvent({
    required Map<String, dynamic> payload,
    required ResultExamStatus status,
    String? source,
  }) {
    final existing = payload[_statusEventsKey];
    final events = <Map<String, dynamic>>[];
    if (existing is List) {
      for (final item in existing) {
        if (item is Map<String, dynamic>) {
          events.add(Map<String, dynamic>.from(item));
        } else if (item is Map) {
          events.add(Map<String, dynamic>.from(item));
        }
      }
    }
    events.add(
      {
        'status': status.value,
        'source': (source == null || source.trim().isEmpty) ? 'unknown' : source,
        'at': DateTime.now().toIso8601String(),
      },
    );
    payload[_statusEventsKey] = events;
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
