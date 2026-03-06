import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Core/LocalStorage/get_local_storage.dart';
import 'package:smart_text_thief/Core/Utils/Enums/enum_user.dart';
import 'package:smart_text_thief/Core/Utils/Extensions/date_time_extension.dart';
import 'package:smart_text_thief/Features/Exams/shared/Enums/exam_lifecycle_status.dart';
import 'package:smart_text_thief/Features/Exams/shared/Enums/level_exam.dart';
import 'package:smart_text_thief/Features/Exams/shared/Models/Results/question_model.dart';
import 'package:smart_text_thief/Features/Exams/shared/Models/score_model.dart';

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
    this.score,
    this.status,
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
  final List<QuestionModel> questions;
  final bool teacherMode;
  final ScoreModel? score;
  final String? status;

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    // Questions: compatible with QuestionModel
    final rawQuestions = json['questions'];
    final parsedQuestions = rawQuestions is List
        ? rawQuestions
            .whereType<Map>()
            .map(
              (item) => QuestionModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <QuestionModel>[];

    return ExamModel(
      id: (json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      levelExam: LevelExam.fromString(json['levelExam'].toString()).name,
      isRandom: json['isRandom'] == true,
      questionCount: _toInt(json['questionCount']),
      statusExam: ExamStatus.fromString((json['status'] ?? '').toString()),
      status: json['status']?.toString(),
      timeMinutes: _toInt(json['timeMinutes']),
      startAt: _parseDateTime(json['startAt']),
      endAt: _parseDateTime(json['endAt']),
      createdAt: _parseDateTime(json['createdAt']),
      questions: parsedQuestions,
      teacherMode: GetLocalStorage.getRoleUser() == UserType.te.value,
      score: json['score'] is Map
          ? ScoreModel.fromJson(Map<String, dynamic>.from(json['score'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "levelExam": levelExam,
        "status": status ?? statusExam.value,
        "isRandom": isRandom,
        "questionCount": questionCount,
        "timeMinutes": timeMinutes,
        "startAt": startAt.toIso8601String(),
        "endAt": endAt.toIso8601String(),
        "createdAt": createdAt.toIso8601String(),
        "questions": questions.map((x) => x.toJson()).toList(),
        "score": score?.toJson(),
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
        score,
        status,
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
    final untilStart = startExam;
    if (untilStart.inSeconds <= 0 && DateTime.now().isBefore(endAt)) {
      return "$text today";
    }
    final hours = untilStart.inHours;
    final day = untilStart.inDays;

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
  Duration get startExam => startAt.difference(DateTime.now());
  DateTime get startedAt => startAt;
  DateTime get examFinishAt => endAt;

  String get specialIdLiveExam => examId;

  bool get doExam =>
      statusExam == ExamStatus.available && !isTeacher && isStart && !isEnded;

  bool get showResult =>
      statusExam == ExamStatus.time ||
      (statusExam == ExamStatus.pendingTime && isEnded);

  bool get showPendingResult =>
      statusExam == ExamStatus.pendingTime && !isEnded;

  bool get isTeacher => statusExam == ExamStatus.instructor || teacherMode;

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime(1970, 1, 1);
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
    List<QuestionModel>? questions,
    bool? teacherMode,
    ScoreModel? score,
    String? status,
    bool clearScore = false,
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
      score: clearScore ? null : (score ?? this.score),
      status: status ?? this.status,
    );
  }
}
