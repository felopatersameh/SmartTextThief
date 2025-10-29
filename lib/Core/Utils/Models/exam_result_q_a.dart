import 'package:equatable/equatable.dart';

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
      questionId: json['questionId'] ?? "",
      questionType: json['questionType'] ?? "",
      questionText: json['questionText'] ?? "",
      options: List<String>.from(json['options'].map((x) => x.toString())),
      correctAnswer: json['correctAnswer'] ?? "",
      studentAnswer: json['studentAnswer'] ?? "",
      score: json['score'].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'questionType': questionType,
    'questionText': questionText,
    'options': options,
    'correctAnswer': correctAnswer,
    'studentAnswer': studentAnswer,
    'score': score?? "-1",
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
