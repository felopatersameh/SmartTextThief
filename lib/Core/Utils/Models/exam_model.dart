import 'package:equatable/equatable.dart';

import '../../Storage/Local/get_local_storage.dart';
import '../Enums/data_key.dart';
import '../Extensions/date_time_extension.dart';
import 'exam_exam_result.dart';
import 'exam_result_static_model.dart';

class ExamModel extends Equatable {
  const ExamModel({
    required this.examId,
    required this.examIdSubject,
    required this.examIdTeacher,
    required this.examResult,
    required this.examStatic,
    required this.examCreatedAt,
    required this.examFinishAt,
    required this.startedAt,
  });

  final String examId;
  final String examIdSubject;
  final String examIdTeacher;
  final List<ExamResultModel> examResult;
  final ExamStaticModel examStatic;
  final DateTime examCreatedAt;
  final DateTime examFinishAt;
  final DateTime startedAt;

  ExamModel copyWith({
    String? examId,
    String? examIdSubject,
    String? examIdTeacher,
    List<ExamResultModel>? examResult,
    ExamStaticModel? examStatic,
    DateTime? examCreatedAt,
    DateTime? examFinishAt,
    DateTime? startedAt,
  }) {
    return ExamModel(
      examId: examId ?? this.examId,
      examIdSubject: examIdSubject ?? this.examIdSubject,
      examIdTeacher: examIdTeacher ?? this.examIdTeacher,
      examResult: examResult ?? this.examResult,
      examStatic: examStatic ?? this.examStatic,
      examCreatedAt: examCreatedAt ?? this.examCreatedAt,
      examFinishAt: examFinishAt ?? this.examFinishAt,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      examId: json[DataKey.examId.key] ?? "",
      examIdSubject: json[DataKey.examIdSubject.key] ?? "",
      examIdTeacher: json[DataKey.examIdTeacher.key] ?? "",
      examResult: json[DataKey.examExamResult.key] == null
          ? []
          : List<ExamResultModel>.from(
              (json[DataKey.examExamResult.key] as List<dynamic>).map(
                (x) => ExamResultModel.fromJson(x),
              ),
            ),
      examStatic: json[DataKey.examStatic.key] == null
          ? ExamStaticModel(
              examResultQA: [],
              levelExam: json[DataKey.levelExam.key] ?? "",
              numberOfQuestions: 0,
              time: "0",
              typeExam: "",
            )
          : ExamStaticModel.fromJson(
              json[DataKey.examStatic.key] as Map<String, dynamic>,
            ),
      examCreatedAt: DateTime.fromMillisecondsSinceEpoch(
        json[DataKey.examCreatedAt.key],
      ),
      examFinishAt: DateTime.fromMillisecondsSinceEpoch(
        json[DataKey.examFinishAt.key],
      ),
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        json[DataKey.examStartedAt.key],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    DataKey.examId.key: examId,
    DataKey.examIdSubject.key: examIdSubject,
    DataKey.examIdTeacher.key: examIdTeacher,
    DataKey.examExamResult.key: examResult.map((x) => x.toJson()).toList(),
    DataKey.examStatic.key: examStatic.toJson(),
    DataKey.examCreatedAt.key: examCreatedAt.millisecondsSinceEpoch,
    DataKey.examFinishAt.key: examFinishAt.millisecondsSinceEpoch,
    DataKey.examStartedAt.key: startedAt.millisecondsSinceEpoch,
  };

  @override
  List<Object?> get props => [
    examId,
    examIdSubject,
    examIdTeacher,
    examResult,
    examStatic,
    examCreatedAt,
    examFinishAt,
    startedAt,
  ];

  String get created => examCreatedAt.shortMonthYear;
  String get started => startedAt.fullDateTime;
  bool get isStart => startedAt.isBefore(DateTime.now());
  bool get isEnded => examFinishAt.isBefore(DateTime.now());
  String get ended => examFinishAt.fullDateTime;
  String get specialIdLiveExam =>
      "${examId.substring(0, 5)}--${GetLocalStorage.getIdUser().substring(0, 5)}";
  bool get isTeacher => (examIdTeacher) == (GetLocalStorage.getIdUser());

  ExamResultModel? get myTest {
    final idSt = GetLocalStorage.getEmailUser();
    final response = examResult.firstWhere(
      (p0) => idSt == p0.examResultEmailSt,
      orElse: () => ExamResultModel.noLabel,
    );
    if (response == ExamResultModel.noLabel) return null;
    return response;
  }

  bool get doExam => (myTest != null);

  bool get showResult =>
      ((myTest != null) || (examFinishAt.isBefore(DateTime.now())))
      ? true
      : false;

  String get durationBeforeStarted {
    final text = "Started in ";
    final hours = examFinishAt.difference(startedAt).inHours;
    final day = examFinishAt.difference(startedAt).inDays;
    if (hours >= 24) return "$text $day Days";
    return "$text $hours H";
  }

  String get durationAfterStarted {
    final text = "Ended in";
    final now = DateTime.now();
    final hours = examFinishAt.difference(now).inHours;
    final day = examFinishAt.difference(now).inDays;
    if (hours >= 24) return "$text $day Days";
    return "$text $hours H";
  }

  int get attempts {
    int attempt = examResult.length;
    if (!doExam && isEnded) attempt += 1;
    return attempt;
  }
}
