import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_result_q_a.dart';
import 'package:smart_text_thief/Features/Exams/do_exam/data/repositories/do_exam_repository.dart';

part 'do_exam_state.dart';

class DoExamCubit extends Cubit<DoExamState> {
  DoExamCubit({DoExamRepository? repository})
      : _repository = repository ?? DoExamRepository(),
        super(DoExamState());

  static const Duration backgroundGraceDuration =
      AppConstants.doExamBackgroundGraceDuration;

  final DoExamRepository _repository;

  String? listenerId;
  int _seconds = 0;
  Timer? _examTimer;
  Timer? _backgroundGraceTimer;
  DateTime? _backgroundAt;
  DateTime? _startTime;
  ExamModel? _currentExam;

  List<ExamResultQA> _shuffleExam(
    List<ExamResultQA> questions,
    bool shouldShuffle,
  ) {
    if (!shouldShuffle) return questions;

    final random = Random();
    final shuffledQuestions = List<ExamResultQA>.from(questions)..shuffle(random);

    return shuffledQuestions.map((question) {
      if (question.questionType == AppConstants.multipleChoiceType &&
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

  Future<void> init(ExamModel model) async {
    await disposeExam();

    _seconds = 0;
    _backgroundAt = null;
    _currentExam = model;
    _startTime = DateTime.now();

    final totalQuestions = model.examStatic.examResultQA.length;
    final examDurationMinutes =
        int.tryParse(model.examStatic.time) ?? AppConstants.minExamDurationMinutes;
    final examDuration = Duration(minutes: examDurationMinutes);
    final questions = _shuffleExam(
      model.examStatic.examResultQA,
      model.examStatic.randomQuestions,
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
    } catch (_) {}

    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _seconds++;

      final now = DateTime.now();
      final elapsed = now.difference(_startTime!);
      final remaining = examDuration - elapsed;

      if (remaining.isNegative || remaining.inSeconds <= 0) {
        timer.cancel();
        await finishExam(model);
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

  Future<void> finishExam(ExamModel model) async {
    if (state.isExamFinished || state.isBlockedBySubmission) return;

    _examTimer?.cancel();
    _examTimer = null;

    var isNewSubmission = false;
    try {
      isNewSubmission = await _repository.submitExam(
        model: model,
        userAnswers: state.userAnswers,
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

    if (isNewSubmission) {
      try {
        await _repository.notifySubmitted(model);
      } catch (_) {}
    }
  }

  bool validateAllQuestionsAnswered() {
    final exam = _currentExam;
    if (exam == null) return false;

    for (final question in exam.examStatic.examResultQA) {
      final answer = state.userAnswers[question.questionId];
      if (!_isAnswerValid(answer)) return false;
    }
    return true;
  }

  int get unansweredQuestionsCount {
    final exam = _currentExam;
    if (exam == null) return 0;

    var unanswered = 0;
    for (final question in exam.examStatic.examResultQA) {
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

    await finishExam(exam);
    return !state.isBlockedBySubmission;
  }

  Future<void> forceFinishExam() async {
    final exam = _currentExam;
    if (exam == null || state.isExamFinished) return;
    await finishExam(exam);
  }

  void onAppBackgrounded() {
    if (state.isExamFinished || _currentExam == null) return;

    _backgroundAt ??= DateTime.now();
    _backgroundGraceTimer?.cancel();
    _backgroundGraceTimer = Timer(backgroundGraceDuration, () async {
      await forceFinishExam();
    });
  }

  Future<void> onAppResumed() async {
    if (state.isExamFinished) return;

    final backgroundAt = _backgroundAt;
    _backgroundAt = null;

    _backgroundGraceTimer?.cancel();
    _backgroundGraceTimer = null;

    if (backgroundAt == null) return;

    final awayDuration = DateTime.now().difference(backgroundAt);
    if (awayDuration >= backgroundGraceDuration) {
      await forceFinishExam();
    }
  }

  Future<void> disposeExam() async {
    _examTimer?.cancel();
    _examTimer = null;

    _backgroundGraceTimer?.cancel();
    _backgroundGraceTimer = null;

    _backgroundAt = null;

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

  @override
  Future<void> close() async {
    await disposeExam();
    return super.close();
  }
}
