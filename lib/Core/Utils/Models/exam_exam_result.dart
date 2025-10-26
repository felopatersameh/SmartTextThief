import 'package:equatable/equatable.dart';
import '../../Storage/Local/get_local_storage.dart';
import '../Enums/data_key.dart';
import '../Enums/level_exam.dart';

import 'exam_result_q_a.dart';

class ExamResultModel extends Equatable {
  const ExamResultModel({
    required this.examResultEmailSt,
    required this.examResultDegree,
    required this.examResultQA,
    required this.levelExam,
    required this.numberOfQuestions,
    this.randomQuestions = false,
    required this.typeExam,
  });

  final String examResultEmailSt;
  final String examResultDegree;
  final List<ExamResultQA> examResultQA;
  final LevelExam levelExam;
  final int numberOfQuestions;
  final bool randomQuestions;
  final String typeExam;

  /// Default noLabel instance (all fields set to "empty" or default values)
  static ExamResultModel noLabel = ExamResultModel(
    examResultEmailSt: "",
    examResultDegree: "",
    examResultQA: const [],
    levelExam: LevelExam.easy,
    numberOfQuestions: 0,
    randomQuestions: false,
    typeExam: "Quiz",
  );

  ExamResultModel copyWith({
    String? examResultEmailSt,
    String? examResultDegree,
    List<ExamResultQA>? examResultQA,
    LevelExam? levelExam,
    int? numberOfQuestions,
    bool? randomQuestions,
    String? typeExam,
  }) {
    return ExamResultModel(
      examResultEmailSt: examResultEmailSt ?? this.examResultEmailSt,
      examResultDegree: examResultDegree ?? this.examResultDegree,
      examResultQA: examResultQA ?? this.examResultQA,
      levelExam: levelExam ?? this.levelExam,
      numberOfQuestions: numberOfQuestions ?? this.numberOfQuestions,
      randomQuestions: randomQuestions ?? this.randomQuestions,
      typeExam: typeExam ?? this.typeExam,
    );
  }

  factory ExamResultModel.fromJson(Map<String, dynamic> json) {
    return ExamResultModel(
      examResultEmailSt: json[DataKey.examResultEmailSt.key] ?? "",
      examResultDegree: json[DataKey.examResultDegree.key] ?? "",
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
    DataKey.examResultEmailSt.key: examResultEmailSt,
    DataKey.examResultDegree.key: examResultDegree,
    DataKey.examResultQandA.key: examResultQA.map((x) => x.toJson()).toList(),
    DataKey.levelExam.key: levelExam.name,
    DataKey.numberOfQuestions.key: numberOfQuestions,
    DataKey.randomQuestions.key: randomQuestions,
    DataKey.typeExam.key: typeExam,
  };

  @override
  List<Object?> get props => [
    examResultEmailSt,
    examResultDegree,
    examResultQA,
    levelExam,
    numberOfQuestions,
    randomQuestions,
    typeExam,
  ];

  bool get isDo => (examResultEmailSt) == (GetLocalStorage.getIdUser());
}
