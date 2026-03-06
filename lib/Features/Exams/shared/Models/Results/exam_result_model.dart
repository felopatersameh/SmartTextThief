import 'package:equatable/equatable.dart';

import '../score_model.dart';
import 'student_answer_model.dart';
import '../student_model.dart';

//* fot this result
class ExamResultModel extends Equatable {
  const ExamResultModel({
    required this.student,
    required this.answers,
    required this.score,
  });

  final StudentModel student;
  final List<StudentAnswerModel> answers;
  final ScoreModel score;

  factory ExamResultModel.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'];
    final parsedAnswers = rawAnswers is List
        ? rawAnswers
            .whereType<Map>()
            .map(
              (item) =>
                  StudentAnswerModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList()
        : <StudentAnswerModel>[];

    return ExamResultModel(
      student: StudentModel.fromJson(
        Map<String, dynamic>.from((json['student'] as Map?) ?? const {}),
      ),
      answers: parsedAnswers,
      score: ScoreModel.fromJson(
        Map<String, dynamic>.from((json['score'] as Map?) ?? const {}),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'student': student.toJson(),
        'answers': answers.map((item) => item.toJson()).toList(),
        'score': score.toJson(),
      };

  ExamResultModel copyWith({
    StudentModel? student,
    List<StudentAnswerModel>? answers,
    ScoreModel? score,
  }) {
    return ExamResultModel(
      student: student ?? this.student,
      answers: answers ?? this.answers,
      score: score ?? this.score,
    );
  }

  @override
  List<Object?> get props => [student, answers, score];
}

