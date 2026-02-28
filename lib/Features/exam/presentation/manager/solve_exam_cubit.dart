import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Features/exam/domain/enums/exam_question_type.dart';
import 'package:smart_text_thief/Features/exam/domain/enums/result_exam_status.dart';
import 'package:smart_text_thief/Features/exam/data/models/exam_model.dart';
import 'package:smart_text_thief/Features/exam/data/models/exam_result_q_a.dart';
import 'package:smart_text_thief/Features/exam/data/models/questions_generated_model.dart';
import 'package:smart_text_thief/Features/exam/data/repositories/do_exam_repository.dart';

part 'solve_exam_state.dart';

class SolveExamCubit extends Cubit<SolveExamState> {
  SolveExamCubit({DoExamRepository? repository})
      : _repository = repository ?? DoExamRepository(),
        super(const SolveExamState());

  static const Duration backgroundGraceDuration =
      AppConstants.doExamBackgroundGraceDuration;

  final DoExamRepository _repository;

  String? listenerId;
  int _seconds = 0;
  Timer? _examTimer;
  Timer? _backgroundGraceTimer;
  Timer? _connectionGraceTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  DateTime? _backgroundAt;
  DateTime? _connectionLostAt;
  DateTime? _startTime;
  ExamModel? _currentExam;
  String _subjectId = '';
  AppLifecycleState _lastLifecycleState = AppLifecycleState.resumed;
  final Connectivity _connectivity = Connectivity();
  final List<ResultExamStatus> _statusHistory = <ResultExamStatus>[];

  List<ExamResultQA> _shuffleExam(
    List<ExamResultQA> questions,
    bool shouldShuffle,
  ) {
    if (!shouldShuffle) return questions;

    final random = Random();
    final shuffledQuestions = List<ExamResultQA>.from(questions)..shuffle(random);

    return shuffledQuestions.map((question) {
      if (question.questionType == ExamQuestionType.multipleChoice.value &&
          question.options.length > 1) {
        final shuffledOptions = List<String>.from(question.options)
          ..shuffle(random);
        return question.copyWith(
          options: shuffledOptions,
          questionId: question.questionId,
        );
      }
      return question;
    }).toList();
  }

  List<ExamResultQA> _mapQuestions(List<QuestionsGeneratedModel> questions) {
    return questions
        .map(
          (question) => ExamResultQA(
            questionId: question.id,
            questionType: question.type,
            questionText: question.text,
            options: (question.options ?? const [])
                .map((item) => item.choice)
                .toList(growable: false),
            correctAnswer: question.correctAnswer,
            studentAnswer: '',
          ),
        )
        .toList(growable: false);
  }

  Future<void> init(ExamModel model, {required String idSubject}) async {
    await disposeExam();

    _seconds = 0;
    _backgroundAt = null;
    _connectionLostAt = null;
    _subjectId = '';
    _currentExam = model;
    _subjectId = idSubject;
    _startTime = DateTime.now();
    _lastLifecycleState = AppLifecycleState.resumed;
    _statusHistory
      ..clear()
      ..add(ResultExamStatus.running);

    final mappedQuestions = _mapQuestions(model.questions);
    final totalQuestions = mappedQuestions.length;
    final examDurationMinutes = model.timeMinutes > 0
        ? model.timeMinutes
        : AppConstants.minExamDurationMinutes;
    final examDuration = Duration(minutes: examDurationMinutes);
    final questions = _shuffleExam(
      mappedQuestions,
      model.isRandom,
    );

    final alreadySubmitted = await _repository.hasStudentSubmitted(model);
    if (alreadySubmitted) {
      emit(
        state.copyWith(
          totalQuestions: totalQuestions,
          remainingTime: examDuration,
          loading: false,
          questions: questions,
          timerExam: 0,
          currentQuestionIndex: 0,
          userAnswers: const {},
          isExamFinished: false,
          isBlockedBySubmission: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        totalQuestions: totalQuestions,
        remainingTime: examDuration,
        loading: false,
        questions: questions,
        timerExam: 0,
        currentQuestionIndex: 0,
        userAnswers: const {},
        isExamFinished: false,
        isBlockedBySubmission: false,
      ),
    );

    try {
      await _repository.createLiveExam(model);
      await _createListeningExam(model);
      _startConnectivityMonitor();
    } catch (_) {}

    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _seconds++;

      final now = DateTime.now();
      final elapsed = now.difference(_startTime!);
      final remaining = examDuration - elapsed;

      if (remaining.isNegative || remaining.inSeconds <= 0) {
        timer.cancel();
        await finishExam(
          model,
          status: ResultExamStatus.timeExpired,
          source: ResultExamStatus.timeExpired.value,
        );
        return;
      }

      emit(
        state.copyWith(
          timerExam: _seconds,
          remainingTime: remaining,
        ),
      );
      await _updateTimer(model);
    });
  }

  void selectAnswer(String questionId, String answer) {
    final updatedAnswers = Map<String, String>.from(state.userAnswers);
    final normalizedAnswer = answer.trim();

    if (normalizedAnswer.isEmpty) {
      updatedAnswers.remove(questionId);
    } else {
      updatedAnswers[questionId] = normalizedAnswer;
    }

    emit(state.copyWith(userAnswers: updatedAnswers));
    unawaited(_updateAnswer(questionId, normalizedAnswer));
  }

  Future<void> _updateAnswer(String questionId, String answer) async {
    final exam = _currentExam;
    if (exam == null) return;

    try {
      await _repository.updateAnswer(
        model: exam,
        questionId: questionId,
        answer: answer,
      );
    } catch (_) {}
  }

  void navigateToQuestion(int index) {
    if (index < 0 || index >= state.totalQuestions) return;
    emit(state.copyWith(currentQuestionIndex: index));
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.totalQuestions - 1) {
      navigateToQuestion(state.currentQuestionIndex + 1);
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      navigateToQuestion(state.currentQuestionIndex - 1);
    }
  }

  Future<void> finishExam(
    ExamModel model, {
    required ResultExamStatus status,
    String? source,
  }) async {
    if (state.isExamFinished || state.isBlockedBySubmission) return;

    _examTimer?.cancel();
    _examTimer = null;
    _backgroundGraceTimer?.cancel();
    _backgroundGraceTimer = null;
    _cancelConnectionGraceTimer();
    _addStatus(status);

    var isNewSubmission = false;
    try {
      isNewSubmission = await _repository.submitExam(
        subjectId: _subjectId,
        model: model,
        userAnswers: state.userAnswers,
        status: status,
        statusHistory: List<ResultExamStatus>.from(_statusHistory),
        source: source,
      );
    } catch (_) {}

    if (!isNewSubmission) {
      emit(
        state.copyWith(
          isExamFinished: false,
          isBlockedBySubmission: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isExamFinished: true,
          isBlockedBySubmission: false,
        ),
      );
    }

    if (listenerId != null) {
      await _repository.unListenLiveExam(listenerId!);
      listenerId = null;
    }

    try {
      await _repository.deleteLiveExam(model);
    } catch (_) {}
  }

  bool validateAllQuestionsAnswered() {
    if (state.questions.isEmpty) return false;
    for (final question in state.questions) {
      final answer = state.userAnswers[question.questionId];
      if (!_isAnswerValid(answer)) return false;
    }
    return true;
  }

  int get unansweredQuestionsCount {
    if (state.questions.isEmpty) return 0;

    var unanswered = 0;
    for (final question in state.questions) {
      final answer = state.userAnswers[question.questionId];
      if (!_isAnswerValid(answer)) {
        unanswered++;
      }
    }
    return unanswered;
  }

  Future<bool> submitExam() async {
    final exam = _currentExam;
    if (exam == null) return false;
    if (state.isBlockedBySubmission) return false;
    if (!validateAllQuestionsAnswered()) return false;

    await finishExam(
      exam,
      status: ResultExamStatus.finished,
      source: ResultExamStatus.finished.value,
    );
    return !state.isBlockedBySubmission;
  }

  Future<void> forceFinishExam({
    ResultExamStatus status = ResultExamStatus.disposed,
    String? source,
  }) async {
    final exam = _currentExam;
    if (exam == null || state.isExamFinished) return;
    await finishExam(
      exam,
      status: status,
      source: source ?? status.value,
    );
  }

  void onAppBackgrounded([AppLifecycleState? lifecycleState]) {
    if (state.isExamFinished || _currentExam == null) return;
    _lastLifecycleState = lifecycleState ?? _lastLifecycleState;

    _backgroundAt ??= DateTime.now();
    _backgroundGraceTimer?.cancel();
    _backgroundGraceTimer = Timer(backgroundGraceDuration, () async {
      await forceFinishExam(
        status: _statusFromLifecycleState(_lastLifecycleState),
        source: _sourceFromLifecycleState(_lastLifecycleState),
      );
    });
  }

  Future<void> onAppResumed() async {
    if (state.isExamFinished) return;
    _lastLifecycleState = AppLifecycleState.resumed;

    final backgroundAt = _backgroundAt;
    _backgroundAt = null;

    _backgroundGraceTimer?.cancel();
    _backgroundGraceTimer = null;

    if (backgroundAt == null) return;

    final awayDuration = DateTime.now().difference(backgroundAt);
    if (awayDuration >= backgroundGraceDuration) {
      await forceFinishExam(
        status: ResultExamStatus.disposed,
        source: 'background_timeout',
      );
    }
  }

  Future<void> disposeExam() async {
    _examTimer?.cancel();
    _examTimer = null;

    _backgroundGraceTimer?.cancel();
    _backgroundGraceTimer = null;

    _cancelConnectionGraceTimer();
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    _backgroundAt = null;
    _connectionLostAt = null;

    if (listenerId != null) {
      await _repository.unListenLiveExam(listenerId!);
      listenerId = null;
    }
  }

  bool _isAnswerValid(String? answer) {
    return answer != null && answer.trim().isNotEmpty;
  }

  Future<void> _updateTimer(ExamModel model) async {
    try {
      await _repository.updateLiveExamTimer(model, state.timerExam);
    } catch (_) {}
  }

  Future<void> _createListeningExam(ExamModel model) async {
    listenerId = _repository.listenLiveExam(
      model,
      (data, key) {},
      onError: (error) {},
    );
  }

  void _startConnectivityMonitor() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (result) {
        _handleConnectivityChanged(result);
      },
      onError: (_) {
        if (state.isExamFinished || _currentExam == null) return;
        _connectionLostAt ??= DateTime.now();
        _connectionGraceTimer ??= Timer(backgroundGraceDuration, () async {
          await forceFinishExam(
            status: ResultExamStatus.connectionLost,
            source: ResultExamStatus.connectionLost.value,
          );
        });
      },
    );
  }

  void _handleConnectivityChanged(List<ConnectivityResult> result) {
    if (state.isExamFinished || _currentExam == null) return;

    final hasConnection =
        result.isNotEmpty && !result.contains(ConnectivityResult.none);
    if (hasConnection) {
      _connectionLostAt = null;
      _cancelConnectionGraceTimer();
      return;
    }

    _connectionLostAt ??= DateTime.now();
    _connectionGraceTimer ??= Timer(backgroundGraceDuration, () async {
      await forceFinishExam(
        status: ResultExamStatus.connectionLost,
        source: ResultExamStatus.connectionLost.value,
      );
    });
  }

  void _cancelConnectionGraceTimer() {
    _connectionGraceTimer?.cancel();
    _connectionGraceTimer = null;
  }

  ResultExamStatus _statusFromLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      return ResultExamStatus.disposed;
    }
    if (state == AppLifecycleState.detached) {
      return ResultExamStatus.unknown;
    }
    return ResultExamStatus.els;
  }

  String _sourceFromLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) return 'app_backgrounded';
    if (state == AppLifecycleState.inactive) return 'app_inactive';
    if (state == AppLifecycleState.detached) return 'app_detached_or_closed';
    return 'else';
  }

  void _addStatus(ResultExamStatus status) {
    if (_statusHistory.isEmpty || _statusHistory.last != status) {
      _statusHistory.add(status);
    }
  }

  @override
  Future<void> close() async {
    await disposeExam();
    return super.close();
  }
}

