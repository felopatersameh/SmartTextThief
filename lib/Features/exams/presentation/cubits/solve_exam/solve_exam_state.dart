part of 'solve_exam_cubit.dart';

class SolveExamState extends Equatable {
  const SolveExamState({
    this.timerExam = 0,
    this.loading = false,
    this.currentQuestionIndex = 0,
    this.userAnswers = const {},
    this.isExamFinished = false,
    this.isBlockedBySubmission = false,
    this.remainingTime = Duration.zero,
    this.totalQuestions = 0,
    this.questions = const [],
  });

  final int timerExam;
  final bool loading;
  final int currentQuestionIndex;
  final Map<String, String> userAnswers;
  final bool isExamFinished;
  final bool isBlockedBySubmission;
  final Duration remainingTime;
  final int totalQuestions;
  final List<ExamResultQA> questions;

  SolveExamState copyWith({
    int? timerExam,
    bool? loading,
    int? currentQuestionIndex,
    Map<String, String>? userAnswers,
    bool? isExamFinished,
    bool? isBlockedBySubmission,
    Duration? remainingTime,
    int? totalQuestions,
    List<ExamResultQA>? questions,
  }) {
    return SolveExamState(
      timerExam: timerExam ?? this.timerExam,
      loading: loading ?? this.loading,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      isExamFinished: isExamFinished ?? this.isExamFinished,
      isBlockedBySubmission:
          isBlockedBySubmission ?? this.isBlockedBySubmission,
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
        isBlockedBySubmission,
        remainingTime,
        totalQuestions,
        questions,
      ];
}
