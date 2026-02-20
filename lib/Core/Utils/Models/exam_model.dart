import 'package:equatable/equatable.dart';

import '../Extensions/date_time_extension.dart';

class ExamModel extends Equatable {
  const ExamModel({
    required this.id,
    required this.name,
    required this.levelExam,
    required this.isRandom,
    required this.questionCount,
    required this.timeMinutes,
    required this.startAt,
    required this.endAt,
    required this.createdAt,
    required this.questions,
  });

  final String id;
  final String name;
  final String levelExam;
  final bool isRandom;
  final int questionCount;
  final int timeMinutes;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime createdAt;
  final List<QuestionsExam> questions;

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json["_id"],
      name: json["name"],
      levelExam: json["levelExam"],
      isRandom: json["isRandom"],
      questionCount: json["questionCount"],
      timeMinutes: json["timeMinutes"],
      startAt: DateTime.tryParse(json["startAt"]) ?? DateTime(2000, 1, 1),
      endAt: DateTime.tryParse(json["endAt"] ?? "") ?? DateTime(2000, 1, 1),
      createdAt:
          DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime(2000, 1, 1),
      questions: json["questions"] == null
          ? []
          : List<QuestionsExam>.from(
              json["questions"]!.map((x) => QuestionsExam.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "levelExam": levelExam,
        "isRandom": isRandom,
        "questionCount": questionCount,
        "timeMinutes": timeMinutes,
        "startAt": startAt.toIso8601String(),
        "endAt": endAt.toIso8601String(),
        "createdAt": createdAt.toIso8601String(),
        "questions": questions.map((x) => x.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        id,
        name,
        levelExam,
        isRandom,
        questionCount,
        timeMinutes,
        startAt,
        endAt,
        createdAt,
        questions,
      ];
// -------------------- Dates --------------------

  String get created => createdAt.shortMonthYear;

  String get started => startAt.fullDateTime;

  String get ended => endAt.fullDateTime;

// -------------------- Status --------------------

  bool get isStart => startAt.isBefore(DateTime.now());

  bool get isEnded => endAt.isBefore(DateTime.now());

// -------------------- Duration --------------------

  String get durationBeforeStarted {
    final text = "Started in ";
    final now = DateTime.now();

    if (now.isAfter(startAt) && now.isBefore(endAt)) {
      return "$text today";
    }

    final hours = endAt.difference(startAt).inHours;
    final day = endAt.difference(startAt).inDays;

    if (hours >= 24) return "$text $day Days";
    return "$text $hours H";
  }

  String get durationAfterStarted {
    final text = "Ended in ";
    final now = DateTime.now();

    final hours = endAt.difference(now).inHours;
    final day = endAt.difference(now).inDays;

    if (hours >= 24) return "$text $day Days";
    return "$text $hours H";
  }


  bool get doExam => true;
  bool get showResult => false;
  int get attempts => 1;
}

class QuestionsExam extends Equatable {
  const QuestionsExam({
    required this.id,
    required this.text,
    required this.type,
    required this.correctAnswer,
    required this.options,
  });

  final String? id;
  final String? text;
  final String? type;
  final String? correctAnswer;
  final List<Option> options;

  factory QuestionsExam.fromJson(Map<String, dynamic> json) {
    return QuestionsExam(
      id: json["id"],
      text: json["text"],
      type: json["type"],
      correctAnswer: json["correctAnswer"],
      options: json["options"] == null
          ? []
          : List<Option>.from(json["options"]!.map((x) => Option.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "text": text,
        "type": type,
        "correctAnswer": correctAnswer,
        "options": options.map((x) => x.toJson()).toList(),
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

class Option extends Equatable {
  const Option({
    required this.id,
    required this.choice,
  });

  final String? id;
  final String? choice;

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json["id"],
      choice: json["choice"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "choice": choice,
      };

  @override
  List<Object?> get props => [
        id,
        choice,
      ];
}
