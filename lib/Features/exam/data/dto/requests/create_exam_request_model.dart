import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Features/exam/data/models/question_model.dart';

class CreateExamRequestModel extends Equatable {
  const CreateExamRequestModel({
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
  final List<QuestionModel> questions;

  factory CreateExamRequestModel.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'];
    final parsedQuestions = rawQuestions is List
        ? rawQuestions
            .whereType<Map>()
            .map((item) => QuestionModel.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <QuestionModel>[];

    return CreateExamRequestModel(
      name: (json['name'] ?? '').toString(),
      levelExam: (json['levelExam'] ?? '').toString(),
      isRandom: json['isRandom'] == true,
      questionCount: _toInt(json['questionCount']),
      timeMinutes: _toInt(json['timeMinutes']),
      startAt: _toDateTime(json['startAt']),
      endAt: _toDateTime(json['endAt']),
      questions: parsedQuestions,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'levelExam': levelExam,
        'isRandom': isRandom,
        'questionCount': questionCount,
        'timeMinutes': timeMinutes,
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
        'questions': questions.map((item) => item.toJson()).toList(),
      };

  CreateExamRequestModel copyWith({
    String? name,
    String? levelExam,
    bool? isRandom,
    int? questionCount,
    int? timeMinutes,
    DateTime? startAt,
    DateTime? endAt,
    List<QuestionModel>? questions,
  }) {
    return CreateExamRequestModel(
      name: name ?? this.name,
      levelExam: levelExam ?? this.levelExam,
      isRandom: isRandom ?? this.isRandom,
      questionCount: questionCount ?? this.questionCount,
      timeMinutes: timeMinutes ?? this.timeMinutes,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      questions: questions ?? this.questions,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime(1970, 1, 1);
  }

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
