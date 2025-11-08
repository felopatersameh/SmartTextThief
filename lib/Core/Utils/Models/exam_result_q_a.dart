import 'package:equatable/equatable.dart';

import '../Enums/data_key.dart';

class ExamResultQA  extends Equatable {
  final String questionId;
  final String questionType;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String studentAnswer;
  final String ? score;

 const ExamResultQA({
    required this.questionId,
    required this.questionType,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.studentAnswer,
     this.score,
  });

  factory ExamResultQA.fromJson(Map<String, dynamic> json) {
    return ExamResultQA(
      questionId: json[DataKey.questionId.key] ?? "",
      questionType: json[DataKey.questionType.key] ?? "",
      questionText: json[DataKey.questionText.key] ?? "",
      options: json[DataKey.options.key] == null
          ? []
          : List<String>.from((json[DataKey.options.key] as List).map((x) => x.toString())),
      correctAnswer: json[DataKey.correctAnswer.key] ?? "",
      studentAnswer: json[DataKey.studentAnswer.key] ?? "",
      score: json[DataKey.score.key]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    DataKey.questionId.key: questionId,
    DataKey.questionType.key: questionType,
    DataKey.questionText.key: questionText,
    DataKey.options.key: options,
    DataKey.correctAnswer.key: correctAnswer,
    DataKey.studentAnswer.key: studentAnswer,
    DataKey.score.key: score ?? "-1",
  };
 
  @override
  List<Object?> get props => [
    questionId,
    questionType,
    questionText,
    options,
    correctAnswer,
    studentAnswer,
    score,
  ];

  ExamResultQA copyWith({
    String? questionId,
    String? questionType,
    String? questionText,
    List<String>? options,
    String? correctAnswer,
    String? studentAnswer,
    String? score,
  }) {
    return ExamResultQA(
      questionId: questionId ?? this.questionId,
      questionType: questionType ?? this.questionType,
      questionText: questionText ?? this.questionText,
      options: options ?? List<String>.from(this.options),
      correctAnswer: correctAnswer ?? this.correctAnswer,
      studentAnswer: studentAnswer ?? this.studentAnswer,
      score: score ?? this.score,
    );
  }

}
