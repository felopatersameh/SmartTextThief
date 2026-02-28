import 'package:equatable/equatable.dart';

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
    final rawOptions = json['options'];
    return ExamResultQA(
      questionId: (json['questionId'] ?? json['id'] ?? '').toString(),
      questionType: (json['questionType'] ?? json['type'] ?? '').toString(),
      questionText: (json['questionText'] ?? json['text'] ?? '').toString(),
      options: rawOptions is List
          ? rawOptions.map((item) => item.toString()).toList(growable: false)
          : const <String>[],
      correctAnswer: (json['correctAnswer'] ?? '').toString(),
      studentAnswer: (json['studentAnswer'] ?? '').toString(),
      score: json['score']?.toString(),
      evaluated: json['evaluated'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'questionType': questionType,
        'questionText': questionText,
        'options': options,
        'correctAnswer': correctAnswer,
        'studentAnswer': studentAnswer,
        if (score != null) 'score': score,
        if (evaluated != null) 'evaluated': evaluated,
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
}

