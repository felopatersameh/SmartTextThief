import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Core/LocalStorage/get_local_storage.dart';
import 'package:smart_text_thief/Core/Utils/Enums/enum_user.dart';
import 'package:smart_text_thief/Core/Utils/Extensions/date_time_extension.dart';
import 'package:smart_text_thief/Features/exam/domain/enums/exam_lifecycle_status.dart';
import 'package:smart_text_thief/Features/exam/domain/enums/level_exam.dart';

import 'questions_generated_model.dart';

// score model (int,int)

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
    required this.statusExam,
    this.teacherMode = false,
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
  final ExamStatus statusExam;
  final List<QuestionsGeneratedModel> questions;
  final bool teacherMode;

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    final parsedQuestions = _parseQuestions(
      json['questions'],
    );
    // score
    return ExamModel(
      id: json['_id'].toString(),
      name: json['name'].toString(),
      levelExam: LevelExam.fromString(json['levelExam'].toString()).name,
      isRandom: json['isRandom'] ?? false,
      questionCount: (json['questionCount'] ?? 0) as int,
      statusExam: ExamStatus.fromString((json['status'] ?? '').toString()),
      timeMinutes: (json['timeMinutes'] ?? 0) as int,
      startAt: _parseDateTime(json['startAt']), //
      endAt: _parseDateTime(json['endAt']), //
      createdAt: _parseDateTime(json['createdAt']), //
      questions: parsedQuestions, //
      teacherMode: GetLocalStorage.getRoleUser() == UserType.te.value,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "levelExam": levelExam,
        "status": statusExam.value,
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
        statusExam,
        teacherMode,
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

  String get examId => id;
  DateTime get startedAt => startAt;
  DateTime get examFinishAt => endAt;

  String get specialIdLiveExam {
    final examName = name;
    final id = examId.length > 5 ? examId.substring(0, 5) : examId;
    return '$examName--$id';
  }

  bool get doExam =>
      statusExam == ExamStatus.available && !isTeacher && isStart && !isEnded;

  bool get showResult =>
      statusExam == ExamStatus.time ||
      (statusExam == ExamStatus.pendingTime && isEnded);

  bool get showPendingResult =>
      statusExam == ExamStatus.pendingTime && !isEnded;

  bool get isTeacher => statusExam == ExamStatus.instructor || teacherMode;

  static List<QuestionsGeneratedModel> _parseQuestions(dynamic raw) {
    if (raw is! List) return const [];
    final parsed = <QuestionsGeneratedModel>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        parsed.add(QuestionsGeneratedModel.fromJson(item));
        continue;
      }
      if (item is Map) {
        parsed.add(
            QuestionsGeneratedModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return parsed;
  }

  static DateTime _parseDateTime(dynamic raw) {
    if (raw is DateTime) return raw;
    if (raw is String) {
      return DateTime.tryParse(raw) ?? DateTime(2000, 1, 1);
    }
    if (raw is int) {
      if (raw < 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(raw * 1000);
      }
      return DateTime.fromMillisecondsSinceEpoch(raw);
    }
    if (raw is double) {
      final value = raw.toInt();
      if (value < 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime(2000, 1, 1);
  }

  ExamModel copyWith({
    String? id,
    String? name,
    String? levelExam,
    bool? isRandom,
    int? questionCount,
    int? timeMinutes,
    DateTime? startAt,
    DateTime? endAt,
    DateTime? createdAt,
    ExamStatus? statusExam,
    List<QuestionsGeneratedModel>? questions,
    bool? teacherMode,
  }) {
    return ExamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      levelExam: levelExam ?? this.levelExam,
      isRandom: isRandom ?? this.isRandom,
      questionCount: questionCount ?? this.questionCount,
      timeMinutes: timeMinutes ?? this.timeMinutes,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      createdAt: createdAt ?? this.createdAt,
      statusExam: statusExam ?? this.statusExam,
      questions: questions ?? this.questions,
      teacherMode: teacherMode ?? this.teacherMode,
    );
  }
}
