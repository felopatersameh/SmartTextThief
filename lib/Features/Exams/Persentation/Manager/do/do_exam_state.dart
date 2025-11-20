  part of 'do_exam_cubit.dart';

class DoExamState extends Equatable {
  final int timerExam;
  final bool loading;
  final int currentQuestionIndex;
  final Map<String, String> userAnswers;
  final bool isExamFinished;
  final Duration remainingTime;
  final int totalQuestions;
  final List<ExamResultQA> questions;

  const DoExamState({
    this.timerExam = 0,
    this.loading = false,
    this.currentQuestionIndex = 0,
    this.userAnswers = const {},
    this.isExamFinished = false,
    this.remainingTime = Duration.zero,
    this.totalQuestions = 0,
    this.questions = const [],
  });

  DoExamState copyWith({
    int? timerExam,
    bool? loading,
    int? currentQuestionIndex,
    Map<String, String>? userAnswers,
    bool? isExamFinished,
    Duration? remainingTime,
    int? totalQuestions,
    List<ExamResultQA>? questions,
  }) {
    return DoExamState(
      timerExam: timerExam ?? this.timerExam,
      loading: loading ?? this.loading,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      isExamFinished: isExamFinished ?? this.isExamFinished,
      remainingTime: remainingTime ?? this.remainingTime,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      questions: questions ?? this.questions,
    );
  }

  @override
  List<Object> get props => [
    timerExam,
    loading,
    currentQuestionIndex,
    userAnswers,
    isExamFinished,
    remainingTime,
    totalQuestions,
    questions,
  ];
}
