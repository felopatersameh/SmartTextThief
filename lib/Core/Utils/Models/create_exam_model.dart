import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Core/Utils/Models/questions_generated_model.dart';

import '../Enums/data_key.dart';

class CreateExamModel extends Equatable {
  const CreateExamModel({
    required this.name,
    required this.levelExam,
    required this.isRandom,
    required this.questionCount,
    required this.timeMinutes,
    required this.startAt,
    required this.endAt,
    required this.questions,
  });

  final String name;
  final String levelExam;
  final bool isRandom;
  final int questionCount;
  final int timeMinutes;
  final DateTime startAt;
  final DateTime endAt;
  final List<QuestionsGeneratedModel> questions;

  factory CreateExamModel.fromJson(Map<String, dynamic> json) {
    return CreateExamModel(
      name: json[DataKey.name.key],
      levelExam: json[DataKey.levelExam.key],
      isRandom: json[DataKey.isRandom.key],
      questionCount: json[DataKey.questionCount.key],
      timeMinutes: json[DataKey.timeMinutes.key],
      startAt: DateTime.tryParse(json[DataKey.startAt.key] ?? "") ??
          DateTime(2000, 1, 1),
      endAt: DateTime.tryParse(json[DataKey.endAt.key] ?? "") ??
          DateTime(2000, 1, 1),
      questions: json[DataKey.questions.key] == null
          ? []
          : List<QuestionsGeneratedModel>.from(json[DataKey.questions.key]!
              .map((x) => QuestionsGeneratedModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        DataKey.name.key: name,
        DataKey.levelExam.key: levelExam,
        DataKey.isRandom.key: isRandom,
        DataKey.questionCount.key: questionCount,
        DataKey.timeMinutes.key: timeMinutes,
        DataKey.startAt.key: startAt.toIso8601String(),
        DataKey.endAt.key: endAt.toIso8601String(),
        DataKey.questions.key: questions.map((x) => x.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        name,
        levelExam,
        isRandom,
        questionCount,
        timeMinutes,
        startAt,
        endAt,
        questions,
      ];
}
