import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_exam_result.dart';
import '../Enums/data_key.dart';

class ExamModel extends Equatable {
  const ExamModel({
    required this.examId,
    required this.examIdSubject,
    required this.examIdTeacher,
    required this.examExamResult,
    required this.examQandA,
    required this.examCreatedAt,
    required this.examFinishAt,
  });

  final String examId;
  final String examIdSubject;
  final String examIdTeacher;
  final List<ExamResult> examExamResult;
  final List<ExamResult> examQandA;
  final DateTime examCreatedAt;
  final DateTime examFinishAt;

  ExamModel copyWith({
    String? examId,
    String? examIdSubject,
    String? examIdTeacher,
    List<ExamResult>? examExamResult,
    List<ExamResult>? examQandA,
    DateTime? examCreatedAt,
    DateTime? examFinishAt,
  }) {
    return ExamModel(
      examId: examId ?? this.examId,
      examIdSubject: examIdSubject ?? this.examIdSubject,
      examIdTeacher: examIdTeacher ?? this.examIdTeacher,
      examExamResult: examExamResult ?? this.examExamResult,
      examQandA: examQandA ?? this.examQandA,
      examCreatedAt: examCreatedAt ?? this.examCreatedAt,
      examFinishAt: examFinishAt ?? this.examFinishAt,
    );
  }

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      examId: json[DataKey.examId.key] ?? "",
      examIdSubject: json[DataKey.examIdSubject.key] ?? "",
      examIdTeacher: json[DataKey.examIdTeacher.key] ?? "",
      examExamResult: json[DataKey.examExamResult.key] == null
          ? []
          : List<ExamResult>.from(
              (json[DataKey.examExamResult.key] as List<dynamic>).map(
                (x) => ExamResult.fromJson(x),
              ),
            ),
      examQandA: json['exam_Q&A'] == null
          ? []
          : List<ExamResult>.from(
              (json['exam_Q&A'] as List<dynamic>).map(
                (x) => ExamResult.fromJson(x),
              ),
            ),
      examCreatedAt:
          DateTime.fromMillisecondsSinceEpoch(json[DataKey.examCreatedAt.key]),
      examFinishAt:
          DateTime.fromMillisecondsSinceEpoch(json[DataKey.examFinishAt.key]),
    );
  }

  Map<String, dynamic> toJson() => {
        DataKey.examId.key: examId,
        DataKey.examIdSubject.key: examIdSubject,
        DataKey.examIdTeacher.key: examIdTeacher,
        DataKey.examExamResult.key:
            examExamResult.map((x) => x.toJson()).toList(),
        'exam_Q&A': examQandA.map((x) => x.toJson()).toList(),
        DataKey.examCreatedAt.key: examCreatedAt.millisecondsSinceEpoch,
        DataKey.examFinishAt.key: examFinishAt.millisecondsSinceEpoch,
      };

  @override
  List<Object?> get props => [
        examId,
        examIdSubject,
        examIdTeacher,
        examExamResult,
        examQandA,
        examCreatedAt,
        examFinishAt,
      ];
}
