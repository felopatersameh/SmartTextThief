import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Core/Utils/Enums/data_key.dart';

import 'questions_generated_model.dart';

class ExamResultQA extends Equatable {
  const ExamResultQA({
    required this.questionId,
    required this.questionType,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.studentAnswer,
    this.score,
    this.evaluated,
  });

  final String questionId;
  final String questionType;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String studentAnswer;
  final String? score;
  final bool? evaluated;

  factory ExamResultQA.fromJson(Map<String, dynamic> json) {
    final questionType =
        (json[DataKey.questionType.key] ?? json[DataKey.type.key] ?? '')
            .toString();
    final studentAnswerRaw =
        (json[DataKey.studentAnswer.key] ?? json['student answer'] ?? '')
            .toString();

    return ExamResultQA(
      questionId: (json[DataKey.questionId.key] ??
              json[DataKey.id.key] ??
              json[DataKey.id_.key] ??
              '')
          .toString(),
      questionType: questionType,
      questionText:
          (json[DataKey.questionText.key] ?? json[DataKey.text.key] ?? '')
              .toString(),
      options: _parseOptions(json[DataKey.options.key]),
      correctAnswer: (json[DataKey.correctAnswer.key] ?? '').toString(),
      studentAnswer: studentAnswerRaw,
      score: json[DataKey.score.key]?.toString(),
      evaluated: json[DataKey.evaluated.key] is bool
          ? json[DataKey.evaluated.key] as bool
          : null,
    );
  }

  factory ExamResultQA.fromGeneratedQuestion(
    QuestionsGeneratedModel question, {
    String studentAnswer = '',
    String? score,
    bool? evaluated,
  }) {
    return ExamResultQA(
      questionId: question.id,
      questionType: question.type,
      questionText: question.text,
      options:
          question.options.map((item) => item.choice).toList(growable: false),
      correctAnswer: question.correctAnswer,
      studentAnswer: studentAnswer.isNotEmpty
          ? studentAnswer
          : (question.studentAnswer ?? ''),
      score: score,
      evaluated: evaluated,
    );
  }

  QuestionsGeneratedModel toGeneratedQuestion() {
    return QuestionsGeneratedModel(
      id: questionId,
      text: questionText,
      type: questionType,
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
      studentAnswer: studentAnswer,
    );
  }

  Map<String, dynamic> toJson() => {
        DataKey.questionId.key: questionId,
        DataKey.questionType.key: questionType,
        DataKey.questionText.key: questionText,
        DataKey.options.key: options,
        DataKey.correctAnswer.key: correctAnswer,
        DataKey.studentAnswer.key: studentAnswer,
        if (score != null) DataKey.score.key: score,
        if (evaluated != null) DataKey.evaluated.key: evaluated,
      };

  ExamResultQA copyWith({
    String? questionId,
    String? questionType,
    String? questionText,
    List<String>? options,
    String? correctAnswer,
    String? studentAnswer,
    String? score,
    bool? evaluated,
  }) {
    return ExamResultQA(
      questionId: questionId ?? this.questionId,
      questionType: questionType ?? this.questionType,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      studentAnswer: studentAnswer ?? this.studentAnswer,
      score: score ?? this.score,
      evaluated: evaluated ?? this.evaluated,
    );
  }

  bool get isCorrectByAnswer =>
      _normalize(studentAnswer) == _normalize(correctAnswer);

  @override
  List<Object?> get props => [
        questionId,
        questionType,
        questionText,
        options,
        correctAnswer,
        studentAnswer,
        score,
        evaluated,
      ];

  static List<String> _parseOptions(dynamic raw) {
    if (raw is! List) return const [];

    final options = <String>[];
    for (final item in raw) {
      if (item is String) {
        options.add(item);
        continue;
      }
      if (item is Map<String, dynamic>) {
        options
            .add((item[DataKey.choice.key] ?? item['text'] ?? '').toString());
        continue;
      }
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        options.add((map[DataKey.choice.key] ?? map['text'] ?? '').toString());
      }
    }
    return options;
  }

  static String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
