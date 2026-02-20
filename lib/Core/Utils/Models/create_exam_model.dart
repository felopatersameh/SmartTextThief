import 'package:equatable/equatable.dart';

import '../Enums/data_key.dart';

class CreateExam extends Equatable {
  const CreateExam({
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

  factory CreateExam.fromJson(Map<String, dynamic> json) {
    return CreateExam(
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

class QuestionsGeneratedModel extends Equatable {
  const QuestionsGeneratedModel({
    required this.id,
    required this.text,
    required this.type,
    required this.correctAnswer,
    required this.options,
  });

  final String id;
  final String text;
  final String type;
  final String correctAnswer;
  final List<OptionQuestionGeneratedModel>? options;

  factory QuestionsGeneratedModel.fromJson(Map<String, dynamic> json) {
    return QuestionsGeneratedModel(
      id: json[DataKey.id.key],
      text: json[DataKey.text.key],
      type: json[DataKey.type.key],
      correctAnswer: json[DataKey.correctAnswer.key],
      options: json[DataKey.options.key] == null
          ? []
          : List<OptionQuestionGeneratedModel>.from(
              json[DataKey.options.key]!.map((x) => OptionQuestionGeneratedModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        DataKey.id.key: id,
        DataKey.text.key: text,
        DataKey.type.key: type,
        DataKey.correctAnswer.key: correctAnswer,
        DataKey.options.key: options?.map((x) => x.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        id,
        text,
        type,
        correctAnswer,
        options,
      ];
}

class OptionQuestionGeneratedModel extends Equatable {
  const OptionQuestionGeneratedModel({
    required this.id,
    required this.choice,
  });

  final String? id;
  final String? choice;

  factory OptionQuestionGeneratedModel.fromJson(Map<String, dynamic> json) {
    return OptionQuestionGeneratedModel(
      id: json[DataKey.id.key],
      choice: json[DataKey.choice.key],
    );
  }

  Map<String, dynamic> toJson() => {
        DataKey.id.key: id,
        DataKey.choice.key: choice,
      };

  @override
  List<Object?> get props => [
        id,
        choice,
      ];
}
