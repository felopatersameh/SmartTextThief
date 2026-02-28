import 'package:smart_text_thief/Features/exam/data/models/exam_result_q_a.dart';
import 'package:smart_text_thief/Features/exam/data/models/questions_generated_model.dart';

class ExamQuestionViewModel {
  const ExamQuestionViewModel({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    required this.correctAnswer,
    this.studentAnswer = '',
    this.score,
    this.evaluated,
  });

  final String id;
  final String text;
  final String type;
  final List<String> options;
  final String correctAnswer;
  final String studentAnswer;
  final String? score;
  final bool? evaluated;

  factory ExamQuestionViewModel.fromGenerated(
    QuestionsGeneratedModel question, {
    String studentAnswer = '',
    String? score,
    bool? evaluated,
  }) {
    return ExamQuestionViewModel(
      id: question.id,
      text: question.text,
      type: question.type,
      options: (question.options ?? const [])
          .map((item) => item.choice)
          .toList(growable: false),
      correctAnswer: question.correctAnswer,
      studentAnswer: studentAnswer.isNotEmpty
          ? studentAnswer
          : (question.studentAnswer ?? ''),
      score: score,
      evaluated: evaluated,
    );
  }

  factory ExamQuestionViewModel.fromResult(ExamResultQA question) {
    return ExamQuestionViewModel(
      id: question.questionId,
      text: question.questionText,
      type: question.questionType,
      options: question.options,
      correctAnswer: question.correctAnswer,
      studentAnswer: question.studentAnswer,
      score: question.score,
      evaluated: question.evaluated,
    );
  }

  QuestionsGeneratedModel toGenerated() {
    return QuestionsGeneratedModel(
      id: id,
      text: text,
      type: type,
      correctAnswer: correctAnswer,
      options: options
          .asMap()
          .entries
          .map(
            (entry) => OptionQuestionGeneratedModel(
              id: '${entry.key + 1}',
              choice: entry.value,
            ),
          )
          .toList(growable: false),
      studentAnswer: studentAnswer.isEmpty ? null : studentAnswer,
    );
  }

  bool get isShortAnswer => options.isEmpty;

  bool isCorrect([String? answer]) {
    return _normalize(answer ?? studentAnswer) == _normalize(correctAnswer);
  }

  ExamQuestionViewModel copyWith({
    String? id,
    String? text,
    String? type,
    List<String>? options,
    String? correctAnswer,
    String? studentAnswer,
    String? score,
    bool? evaluated,
  }) {
    return ExamQuestionViewModel(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      studentAnswer: studentAnswer ?? this.studentAnswer,
      score: score ?? this.score,
      evaluated: evaluated ?? this.evaluated,
    );
  }

  static String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

