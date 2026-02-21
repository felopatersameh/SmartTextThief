import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Core/LocalStorage/get_local_storage.dart';

import '../Enums/exam_lifecycle_status.dart';
import '../Enums/level_exam.dart';
import '../Extensions/date_time_extension.dart';
import 'exam_exam_result.dart';
import 'exam_result_q_a.dart';
import 'questions_generated_model.dart';
import 'result_exam_model.dart';

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
    this.subjectId = '',
    this.teacherId = '',
    this.geminiModel = '',
    this.studentResults = const [],
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
  final String subjectId;
  final String teacherId;
  final String geminiModel;
  final bool teacherMode;
  final List<ResultExamModel> studentResults;

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    final map = _toMap(json);
    final staticMap = _toMap(map['exam_static']);

    final parsedQuestions = _parseQuestions(
      map['questions'] ?? staticMap['questions'] ?? staticMap['examResult_Q&A'],
    );
    final parsedResults = _parseStudentResults(
      map['results'] ?? map['exam_ExamResult'],
    );

    final fallbackQuestionCount = parsedQuestions.length;
    final fallbackName = (staticMap['typeExam'] ?? '').toString();
    final fallbackLevel = (staticMap['levelExam'] ?? '').toString();
    final fallbackRandom = _toBool(staticMap['randomQuestions']) ?? false;
    final fallbackTime = _toInt(staticMap['time']) ?? 0;

    return ExamModel(
      id: (map['_id'] ?? map['exam_id'] ?? map['id'] ?? '').toString(),
      subjectId: (map['subjectId'] ?? map['exam_idSubject'] ?? '').toString(),
      teacherId: (map['teacherId'] ?? map['exam_idTeacher'] ?? '').toString(),
      name: (map['name'] ?? fallbackName).toString(),
      levelExam: (map['levelExam'] ?? fallbackLevel).toString(),
      isRandom: _toBool(map['isRandom']) ?? fallbackRandom,
      questionCount: _toInt(map['questionCount']) ??
          _toInt(staticMap['numberOfQuestions']) ??
          fallbackQuestionCount,
      statusExam: ExamStatus.fromString((map['status'] ?? '').toString()),
      timeMinutes: _toInt(map['timeMinutes']) ?? fallbackTime,
      startAt: _parseDateTime(
        map['startAt'] ?? map['startedAt'] ?? map['exam_startedAt'],
      ),
      endAt: _parseDateTime(
        map['endAt'] ?? map['exam_FinishAt'],
      ),
      createdAt: _parseDateTime(
        map['createdAt'] ?? map['exam_createdAt'],
      ),
      questions: parsedQuestions,
      geminiModel:
          (map['geminiModel'] ?? staticMap['geminiModel'] ?? '').toString(),
      studentResults: parsedResults,
      teacherMode: _toBool(map['isTeacher']) ?? false,
    );
  }

  ExamModel copyWith({
    String? id,
    String? subjectId,
    String? teacherId,
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
    String? geminiModel,
    bool? teacherMode,
    List<ResultExamModel>? studentResults,
    DateTime? startedAt,
    DateTime? examFinishAt,
    ExamStaticModel? examStatic,
    List<ExamResultModel>? examResult,
  }) {
    final nextQuestions = questions ??
        (examStatic != null
            ? examStatic.examResultQA
                .map((qa) => qa.toGeneratedQuestion())
                .toList(growable: false)
            : this.questions);

    final nextStudentResults = studentResults ??
        (examResult != null
            ? examResult
                .map((item) => item.toResultExamModel(idExam: this.id))
                .toList(growable: false)
            : this.studentResults);

    final fromStatic = examStatic;

    return ExamModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      name: name ?? fromStatic?.typeExam ?? this.name,
      levelExam: levelExam ?? fromStatic?.levelExam.name ?? this.levelExam,
      isRandom: isRandom ?? fromStatic?.randomQuestions ?? this.isRandom,
      questionCount:
          questionCount ?? fromStatic?.numberOfQuestions ?? this.questionCount,
      timeMinutes:
          timeMinutes ?? (_toInt(fromStatic?.time) ?? this.timeMinutes),
      startAt: startAt ?? startedAt ?? this.startAt,
      endAt: endAt ?? examFinishAt ?? this.endAt,
      createdAt: createdAt ?? this.createdAt,
      statusExam: statusExam ?? this.statusExam,
      questions: nextQuestions,
      geminiModel: geminiModel ?? fromStatic?.geminiModel ?? this.geminiModel,
      teacherMode: teacherMode ?? this.teacherMode,
      studentResults: nextStudentResults,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "subjectId": subjectId,
        "teacherId": teacherId,
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
        if (studentResults.isNotEmpty)
          "results": studentResults.map((x) => x.toJson()).toList(),
        if (geminiModel.isNotEmpty) "geminiModel": geminiModel,
      };

  @override
  List<Object?> get props => [
        id,
        subjectId,
        teacherId,
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
        geminiModel,
        studentResults,
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
  String get examIdSubject => subjectId;
  String get examIdTeacher => teacherId;
  DateTime get startedAt => startAt;
  DateTime get examFinishAt => endAt;

  String get specialIdLiveExam {
    final examPart = id.length > 5 ? id.substring(0, 5) : id;
    final owner =
        teacherId.isNotEmpty ? teacherId : GetLocalStorage.getEmailUser();
    final ownerPart = owner.length > 5 ? owner.substring(0, 5) : owner;
    if (examPart.isEmpty) return id;
    if (ownerPart.isEmpty) return examPart;
    return '$examPart--$ownerPart';
  }

  bool get isTeacher =>
      teacherMode ||
      (teacherId.isNotEmpty && teacherId == GetLocalStorage.getEmailUser());

  ExamStaticModel get examStatic => ExamStaticModel(
        examResultQA: questions
            .map((question) => ExamResultQA.fromGeneratedQuestion(question))
            .toList(growable: false),
        levelExam: LevelExam.fromString(levelExam),
        numberOfQuestions: questionCount,
        randomQuestions: isRandom,
        typeExam: name,
        time: timeMinutes.toString(),
        geminiModel: geminiModel,
      );

  List<ExamResultModel> get examResult => studentResults
      .map((result) => ExamResultModel.fromResultExamModel(
            result,
            levelExam: LevelExam.fromString(levelExam),
            numberOfQuestions: questionCount,
            randomQuestions: isRandom,
            typeExam: name,
          ))
      .toList(growable: false);

  ExamResultModel? get myTest {
    final email = GetLocalStorage.getEmailUser().trim().toLowerCase();
    if (email.isEmpty || examResult.isEmpty) return null;
    for (final result in examResult) {
      if (result.examResultEmailSt.trim().toLowerCase() == email) {
        return result;
      }
    }
    return null;
  }

  bool get doExam => myTest != null || statusExam == ExamStatus.time;
  bool get showResult => doExam || isEnded;

  int get attempts {
    var attempt = examResult.length;
    if (!doExam && isEnded) {
      attempt += 1;
    }
    return attempt;
  }

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

  static List<ResultExamModel> _parseStudentResults(dynamic raw) {
    if (raw is! List) return const [];
    final parsed = <ResultExamModel>[];

    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        parsed.add(_parseResultItem(item));
        continue;
      }
      if (item is Map) {
        parsed.add(_parseResultItem(Map<String, dynamic>.from(item)));
      }
    }

    return parsed;
  }

  static ResultExamModel _parseResultItem(Map<String, dynamic> map) {
    final hasLegacyKeys = map.containsKey('examResult_emailSt') ||
        map.containsKey('examResult_degree') ||
        map.containsKey('examResult_Q&A');

    if (!hasLegacyKeys) {
      return ResultExamModel.fromJson(map);
    }

    final qaRaw = map['examResult_Q&A'];
    final qaList = <Result>[];
    if (qaRaw is List) {
      for (final qa in qaRaw) {
        if (qa is Map<String, dynamic>) {
          qaList.add(
            Result(
              id: (qa['questionId'] ?? qa['id'] ?? '').toString(),
              studentAnswer: (qa['studentAnswer'] ?? qa['student answer'] ?? '')
                  .toString(),
              score: qa['score']?.toString(),
              evaluated:
                  qa['evaluated'] is bool ? qa['evaluated'] as bool : null,
            ),
          );
          continue;
        }
        if (qa is Map) {
          final data = Map<String, dynamic>.from(qa);
          qaList.add(
            Result(
              id: (data['questionId'] ?? data['id'] ?? '').toString(),
              studentAnswer:
                  (data['studentAnswer'] ?? data['student answer'] ?? '')
                      .toString(),
              score: data['score']?.toString(),
              evaluated:
                  data['evaluated'] is bool ? data['evaluated'] as bool : null,
            ),
          );
        }
      }
    }

    return ResultExamModel(
      name: (map['examResult_emailSt'] ?? '').toString(),
      idExam: (map['idExam'] ?? map['examId'] ?? '').toString(),
      score: (map['examResult_degree'] ?? '0').toString(),
      timeTakenMs: (map['timeTakenMs'] ?? '0').toString(),
      results: qaList,
    );
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

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
    return null;
  }

  static Map<String, dynamic> _toMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }
}

class ExamStaticModel extends Equatable {
  const ExamStaticModel({
    required this.examResultQA,
    required this.levelExam,
    required this.numberOfQuestions,
    required this.randomQuestions,
    required this.typeExam,
    required this.time,
    this.geminiModel = '',
  });

  final List<ExamResultQA> examResultQA;
  final LevelExam levelExam;
  final int numberOfQuestions;
  final bool randomQuestions;
  final String typeExam;
  final String time;
  final String geminiModel;

  ExamStaticModel copyWith({
    List<ExamResultQA>? examResultQA,
    LevelExam? levelExam,
    int? numberOfQuestions,
    bool? randomQuestions,
    String? typeExam,
    String? time,
    String? geminiModel,
  }) {
    return ExamStaticModel(
      examResultQA: examResultQA ?? this.examResultQA,
      levelExam: levelExam ?? this.levelExam,
      numberOfQuestions: numberOfQuestions ?? this.numberOfQuestions,
      randomQuestions: randomQuestions ?? this.randomQuestions,
      typeExam: typeExam ?? this.typeExam,
      time: time ?? this.time,
      geminiModel: geminiModel ?? this.geminiModel,
    );
  }

  Map<String, dynamic> toJson() => {
        'examResult_Q&A': examResultQA.map((x) => x.toJson()).toList(),
        'levelExam': levelExam.name,
        'numberOfQuestions': numberOfQuestions,
        'randomQuestions': randomQuestions,
        'typeExam': typeExam,
        'time': time,
        if (geminiModel.isNotEmpty) 'geminiModel': geminiModel,
      };

  @override
  List<Object?> get props => [
        examResultQA,
        levelExam,
        numberOfQuestions,
        randomQuestions,
        typeExam,
        time,
        geminiModel,
      ];
}
