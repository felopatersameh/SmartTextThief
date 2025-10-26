import 'package:equatable/equatable.dart';
import '../Enums/data_key.dart';
import '../Enums/level_exam.dart';

import 'exam_result_q_a.dart';

class ExamStaticModel extends Equatable {
  const ExamStaticModel({
    required this.examResultQA,
    required this.levelExam,
    required this.numberOfQuestions,
    this.randomQuestions = false,
    required this.typeExam,
  });

  final List<ExamResultQA> examResultQA;
  final LevelExam levelExam;
  final int numberOfQuestions;
  final bool randomQuestions;
  final String typeExam;

  ExamStaticModel copyWith({
    List<ExamResultQA>? examResultQA,
    LevelExam? levelExam,
    int? numberOfQuestions,
    bool? randomQuestions,
    String? typeExam,
  }) {
    return ExamStaticModel(
      examResultQA: examResultQA ?? this.examResultQA,
      levelExam: levelExam ?? this.levelExam,
      numberOfQuestions: numberOfQuestions ?? this.numberOfQuestions,
      randomQuestions: randomQuestions ?? this.randomQuestions,
      typeExam: typeExam ?? this.typeExam,
    );
  }

  factory ExamStaticModel.fromJson(Map<String, dynamic> json) {
    return ExamStaticModel(
      examResultQA: json[DataKey.examResultQandA.key] == null
          ? []
          : List<ExamResultQA>.from(
              (json[DataKey.examResultQandA.key] as List<dynamic>).map(
                (x) => ExamResultQA.fromJson(x as Map<String, dynamic>),
              ),
            ),
      levelExam: LevelExam.fromString(json[DataKey.levelExam.key]),
      numberOfQuestions:
          int.tryParse(json[DataKey.numberOfQuestions.key]?.toString() ?? '') ??
          0,
      randomQuestions: json[DataKey.randomQuestions.key] ?? false,
      typeExam: json[DataKey.typeExam.key] ?? "Quiz",
    );
  }

  Map<String, dynamic> toJson() => {
    DataKey.examResultQandA.key: examResultQA.map((x) => x.toJson()).toList(),
    DataKey.levelExam.key: levelExam.name,
    DataKey.numberOfQuestions.key: numberOfQuestions,
    DataKey.randomQuestions.key: randomQuestions,
    DataKey.typeExam.key: typeExam,
  };

  @override
  List<Object?> get props => [
    examResultQA,
    levelExam,
    numberOfQuestions,
    randomQuestions,
    typeExam,
  ];
}
