import 'package:equatable/equatable.dart';

import 'question_model.dart';
import 'score_model.dart';

class ExamModel extends Equatable {
  const ExamModel({
    required this.id,
    required this.name,
    required this.levelExam,
    required this.status,
    required this.score,
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
  final String? status;
  final ScoreModel? score;
  final bool isRandom;
  final int questionCount;
  final int timeMinutes;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime? createdAt;
  final List<QuestionModel> questions;

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'];
    final parsedQuestions = rawQuestions is List
        ? rawQuestions
            .whereType<Map>()
            .map((item) => QuestionModel.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <QuestionModel>[];

    return ExamModel(
      id: (json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      levelExam: (json['levelExam'] ?? '').toString(),
      status: json['status']?.toString(),
      score: json['score'] is Map
          ? ScoreModel.fromJson(Map<String, dynamic>.from(json['score'] as Map))
          : null,
      isRandom: json['isRandom'] == true,
      questionCount: _toInt(json['questionCount']),
      timeMinutes: _toInt(json['timeMinutes']),
      startAt: _toDateTime(json['startAt']),
      endAt: _toDateTime(json['endAt']),
      createdAt: _toNullableDateTime(json['createdAt']),
      questions: parsedQuestions,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'levelExam': levelExam,
        'status': status,
        'score': score?.toJson(),
        'isRandom': isRandom,
        'questionCount': questionCount,
        'timeMinutes': timeMinutes,
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'questions': questions.map((item) => item.toJson()).toList(),
      };

  ExamModel copyWith({
    String? id,
    String? name,
    String? levelExam,
    String? status,
    ScoreModel? score,
    bool clearScore = false,
    bool? isRandom,
    int? questionCount,
    int? timeMinutes,
    DateTime? startAt,
    DateTime? endAt,
    DateTime? createdAt,
    bool clearCreatedAt = false,
    List<QuestionModel>? questions,
  }) {
    return ExamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      levelExam: levelExam ?? this.levelExam,
      status: status ?? this.status,
      score: clearScore ? null : (score ?? this.score),
      isRandom: isRandom ?? this.isRandom,
      questionCount: questionCount ?? this.questionCount,
      timeMinutes: timeMinutes ?? this.timeMinutes,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      createdAt: clearCreatedAt ? null : (createdAt ?? this.createdAt),
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

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [
        id,
        name,
        levelExam,
        status,
        score,
        isRandom,
        questionCount,
        timeMinutes,
        startAt,
        endAt,
        createdAt,
        questions,
      ];
}