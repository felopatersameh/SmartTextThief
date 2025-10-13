import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Core/Utils/Enums/data_key.dart';

class ExamExamResult extends Equatable {
  const ExamExamResult({
    required this.examResultEmailSt,
    required this.examResultDegree,
    required this.examResultQA,
  });

  final String examResultEmailSt;
  final String examResultDegree;
  final List<dynamic> examResultQA;

  ExamExamResult copyWith({
    String? examResultEmailSt,
    String? examResultDegree,
    List<dynamic>? examResultQA,
  }) {
    return ExamExamResult(
      examResultEmailSt: examResultEmailSt ?? this.examResultEmailSt,
      examResultDegree: examResultDegree ?? this.examResultDegree,
      examResultQA: examResultQA ?? this.examResultQA,
    );
  }

  factory ExamExamResult.fromJson(Map<String, dynamic> json) {
    return ExamExamResult(
      examResultEmailSt: json[DataKey.examResultEmailSt.key] ?? "",
      examResultDegree: json[DataKey.examResultDegree.key] ?? "",
      examResultQA: json[DataKey.examResultQandA.key] == null
          ? []
          : List<dynamic>.from(
              json[DataKey.examResultQandA.key]!.map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
        DataKey.examResultEmailSt.key: examResultEmailSt,
        DataKey.examResultDegree.key: examResultDegree,
        DataKey.examResultQandA.key:
            examResultQA.map((x) => x).toList(),
      };

  @override
  List<Object?> get props => [
        examResultEmailSt,
        examResultDegree,
        examResultQA,
      ];
}
