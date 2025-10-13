import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_exam_result.dart';
import '../Enums/data_key.dart';

class ExamModel extends Equatable {
  const ExamModel({
    required this.examId,
    required this.examIdSubject,
    required this.examIdTeacher,
    required this.examExamResult,
    required this.examCreatedAt,
    required this.examFinishAt,
  });

  final String examId;
  final String examIdSubject;
  final String examIdTeacher;
  final List<ExamExamResult> examExamResult;
  final DateTime? examCreatedAt;
  final DateTime? examFinishAt;

  ExamModel copyWith({
    String? examId,
    String? examIdSubject,
    String? examIdTeacher,
    List<ExamExamResult>? examExamResult,
    DateTime? examCreatedAt,
    DateTime? examFinishAt,
  }) {
    return ExamModel(
      examId: examId ?? this.examId,
      examIdSubject: examIdSubject ?? this.examIdSubject,
      examIdTeacher: examIdTeacher ?? this.examIdTeacher,
      examExamResult: examExamResult ?? this.examExamResult,
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
          : List<ExamExamResult>.from(
              json[DataKey.examExamResult.key]!
                  .map((x) => ExamExamResult.fromJson(x))),
      examCreatedAt: DateTime.tryParse(json[DataKey.examCreatedAt.key] ?? ""),
      examFinishAt: DateTime.tryParse(json[DataKey.examFinishAt.key] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
        DataKey.examId.key: examId,
        DataKey.examIdSubject.key: examIdSubject,
        DataKey.examIdTeacher.key: examIdTeacher,
        DataKey.examExamResult.key:
            examExamResult.map((x) => x.toJson()).toList(),
        DataKey.examCreatedAt.key: examCreatedAt == null
            ? null
            : "${examCreatedAt!.year.toString().padLeft(4, '0')}-${examCreatedAt!.month.toString().padLeft(2, '0')}-${examCreatedAt!.day.toString().padLeft(2, '0')}",
        DataKey.examFinishAt.key: examFinishAt == null
            ? null
            : "${examFinishAt!.year.toString().padLeft(4, '0')}-${examFinishAt!.month.toString().padLeft(2, '0')}-${examFinishAt!.day.toString().padLeft(2, '0')}",
      };

  @override
  List<Object?> get props => [
        examId,
        examIdSubject,
        examIdTeacher,
        examExamResult,
        examCreatedAt,
        examFinishAt,
      ];
}
