import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../Core/Services/Notifications/notification_services.dart';
import '../../../../../Core/Services/Notifications/notification_model.dart';
import '../../../../../../Core/Services/Firebase/firebase_service.dart';
import '../../../../../Core/LocalStorage/get_local_storage.dart';
import '../../../../../../Core/Utils/Enums/collection_key.dart';
import '../../../../../../Core/Utils/Enums/data_key.dart';
import '../../../../../../Core/Utils/Enums/notification_type.dart';
import '../../../../../../Core/Utils/Models/exam_exam_result.dart';
import '../../../../../../Core/Utils/Models/exam_model.dart';

import '../../../../../../Core/Services/Firebase/real_time_firbase.dart';
import '../../../../../../Core/Utils/Models/exam_result_q_a.dart';

part 'do_exam_state.dart';

class DoExamCubit extends Cubit<DoExamState> {
  DoExamCubit() : super(DoExamState());
  static const Duration backgroundGraceDuration = Duration(minutes: 2);
  String? listenerId;
  int seconds = 0;
  Timer? examTimer;
  Timer? _backgroundGraceTimer;
  DateTime? _backgroundAt;
  ExamModel? currentExam;
  DateTime? startTime;
  ExamModel? examModel;
  List<ExamResultQA> _shuffleExam(
      List<ExamResultQA> questions, bool shouldShuffle) {
    if (!shouldShuffle) return questions;

    final random = Random();

    final shuffledQuestions = List<ExamResultQA>.from(questions)
      ..shuffle(random);

    return shuffledQuestions.map((question) {
      if (question.questionType == 'multiple_choice' &&
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
    seconds = 0;
    _backgroundAt = null;
    examModel = model;
    currentExam = model;
    startTime = DateTime.now();
    final totalQuestions = model.examStatic.examResultQA.length;

    // Convert minutes to Duration
    final examDurationMinutes = int.tryParse(model.examStatic.time) ?? 10;
    final examDuration = Duration(minutes: examDurationMinutes);
    final checkRandom = model.examStatic.randomQuestions;
    final questions = _shuffleExam(model.examStatic.examResultQA, checkRandom);

    emit(
      state.copyWith(
          totalQuestions: totalQuestions,
          remainingTime: examDuration,
          loading: false,
          questions: questions),
    );

    try {
      await createData(model);
      await createListeningExam(model);
    } catch (_) {}

    // Start exam timer
    examTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      seconds++;

      // Calculate remaining time
      final now = DateTime.now();
      final elapsed = now.difference(startTime!);
      final remaining = examDuration - elapsed;

      if (remaining.isNegative || remaining.inSeconds <= 0) {
        // Exam time finished
        timer.cancel();
        await finishExam(model);
        return;
      }

      emit(state.copyWith(timerExam: seconds, remainingTime: remaining));
      await updateData(model);
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

    // Update Firebase with the selected answer
    updateAnswerInFirebase(questionId, normalizedAnswer);
  }

  Future<void> updateAnswerInFirebase(String questionId, String answer) async {
    if (examModel == null) return;

    try {
      // Find the question and update its student answer
      final questionIndex = examModel!.examStatic.examResultQA.indexWhere(
        (q) => q.questionId == questionId,
      );

      if (questionIndex != -1) {
        final question = examModel!.examStatic.examResultQA[questionIndex];
        final updatedQuestion = question.copyWith(studentAnswer: answer);

        // Update only the specific question in Firebase
        final updateData = {questionId: updatedQuestion.toJson()};

        await RealtimeFirebase.updateData(
          "Exam_Live/${examModel!.specialIdLiveExam}",
          updateData,
        );

        //log\("✅ Answer updated for question $questionId: $answer");
      }
    } catch (e) {
      //log\("❌ Error updating answer: $e");
    }
  }

  void navigateToQuestion(int index) {
    if (index >= 0 && index < state.totalQuestions) {
      emit(state.copyWith(currentQuestionIndex: index));
    }
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
    if (state.isExamFinished) return;

    emit(state.copyWith(isExamFinished: true));
    examTimer?.cancel();

    if (examModel != null) {
      final Map<String, dynamic> resultsUpdate = {};
      int totalScore = 0;

      for (var question in examModel!.examStatic.examResultQA) {
        final studentAnswer = state.userAnswers[question.questionId] ?? '';
        final correctAnswer =
            question.correctAnswer; // assuming correctAnswer property exists
        final isCorrect = studentAnswer == correctAnswer;
        final score = isCorrect ? 1 : 0;
        totalScore += score;

        resultsUpdate[question.questionId] = {
          ...question.toJson(),
          "studentAnswer": studentAnswer,
          "score": score,
          "evaluated": true,
        };
      }
      final emailStudent = GetLocalStorage.getEmailUser();
      final List<ExamResultQA> examResultQA = resultsUpdate.values
          .map((e) => ExamResultQA.fromJson(e as Map<String, dynamic>))
          .toList();
      final ExamResultModel lastModel = ExamResultModel(
        examResultEmailSt: emailStudent,
        examResultDegree: totalScore.toString(),
        examResultQA: examResultQA,
        levelExam: examModel!.examStatic.levelExam,
        numberOfQuestions: examModel!.examStatic.numberOfQuestions,
        typeExam: examModel!.examStatic.typeExam,
      );

      final latestExamResponse = await FirebaseServices.instance.getData(
        model.examIdSubject,
        CollectionKey.subjects.key,
        subCollections: [CollectionKey.exams.key],
        subIds: [model.examId],
      );

      final List<Map<String, dynamic>> mergedResults = [];
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
      mergedResults.add(lastModel.toJson());

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

    if (listenerId != null) {
      await RealtimeFirebase.unListen(listenerId!);
      listenerId = null;
    }
    try {
      await RealtimeFirebase.deleteData("Exam_Live/${model.specialIdLiveExam}");
    } catch (_) {}
    final nameParts = GetLocalStorage.getNameUser().split(" ");
    final name = nameParts.length >= 2
        ? "${nameParts[0]} ${nameParts[1]}"
        : GetLocalStorage.getNameUser();
    final length = model.examResult.isEmpty || model.examResult.length - 1 == 0;
    final String and = length ? "" : "and ${model.examResult.length} members";
    final notification = NotificationModel(
      id: "doExam_${model.examId}",
      topicId: "${model.examIdSubject}_admin",
      type: NotificationType.submit,
      body:
          "$name Submitted Exam ${model.examStatic.typeExam} ${model.specialIdLiveExam} $and",
    );
    await NotificationServices.sendNotificationToTopic(
      id: notification.id,
      data: notification.toJson(),
      stringData: notification.toJsonString(),
    );
  }

  bool validateAllQuestionsAnswered() {
    if (examModel == null) return false;
    for (final question in examModel!.examStatic.examResultQA) {
      final answer = state.userAnswers[question.questionId];
      if (!_isAnswerValid(answer)) {
        return false;
      }
    }
    return true;
  }

  int get unansweredQuestionsCount {
    if (examModel == null) return 0;
    int unanswered = 0;
    for (final question in examModel!.examStatic.examResultQA) {
      final answer = state.userAnswers[question.questionId];
      if (!_isAnswerValid(answer)) {
        unanswered++;
      }
    }
    return unanswered;
  }

  Future<bool> submitExam() async {
    if (currentExam == null) return false;

    // Check if all questions are answered
    if (!validateAllQuestionsAnswered()) {
      return false;
    }

    await finishExam(currentExam!);
    return true;
  }

  Future<void> forceFinishExam() async {
    if (currentExam != null && !state.isExamFinished) {
      //log\(
      //   '⚠️ Forcing exam finish - user exited without completing all questions',
      // );
      await finishExam(currentExam!);
    }
  }

  void onAppBackgrounded() {
    if (state.isExamFinished || currentExam == null) return;
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
    examTimer?.cancel();
    examTimer = null;
    _backgroundGraceTimer?.cancel();
    _backgroundGraceTimer = null;
    _backgroundAt = null;
    if (listenerId != null) {
      await RealtimeFirebase.unListen(listenerId!);
      listenerId = null;
    }
  }

  bool _isAnswerValid(String? answer) => answer != null && answer.trim().isNotEmpty;

  @override
  Future<void> close() async {
    await disposeExam();
    return super.close();
  }

  Future<void> createData(ExamModel model) async {
    final Map<String, dynamic> map = {};
    final Map<String, dynamic> otherMap = {
      "start_time": DateTime.now().millisecondsSinceEpoch,
      'time': 0,
      'dispose_exam': 0,
    };
    for (var element in model.examStatic.examResultQA) {
      map[element.questionId] = element.toJson();
    }
    await RealtimeFirebase.create(
      "Exam_Live",
      map,
      otherData: otherMap,
      id: model.specialIdLiveExam,
    );
  }

  Future<void> updateData(ExamModel model) async {
    try {
      final Map<String, dynamic> timerUpdate = {
        'time': state.timerExam,
        'dispose_exam': 0,
      };
      await RealtimeFirebase.updateData(
        "Exam_Live/${model.specialIdLiveExam}",
        {},
        otherUpdates: timerUpdate,
      );
    } catch (_) {}
  }

  Future<void> createListeningExam(ExamModel model) async {
    listenerId = RealtimeFirebase.listen(
      "Exam_Live/${model.specialIdLiveExam}",
      (data, key) {
        //log\("key::$key");
        //log\("data::${data['time'].toString()}");
      },
      onError: (error) {
        //log\("error listen '${model.specialIdLiveExam}' :: $error");
      },
    );
  }
}
