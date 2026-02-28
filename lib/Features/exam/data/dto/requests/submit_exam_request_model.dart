import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Features/exam/data/models/student_answer_model.dart';

class SubmitExamRequestModel extends Equatable {
  const SubmitExamRequestModel({
    required this.status,
    required this.answers,
  });

  final String status;
  final List<StudentAnswerModel> answers;

  factory SubmitExamRequestModel.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'];
    final parsedAnswers = rawAnswers is List
        ? rawAnswers
            .whereType<Map>()
            .map(
              (item) =>
                  StudentAnswerModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList()
        : <StudentAnswerModel>[];

    return SubmitExamRequestModel(
      status: (json['status'] ?? '').toString(),
      answers: parsedAnswers,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'answers': answers.map((item) => item.toSubmitJson()).toList(),
      };

  SubmitExamRequestModel copyWith({
    String? status,
    List<StudentAnswerModel>? answers,
  }) {
    return SubmitExamRequestModel(
      status: status ?? this.status,
      answers: answers ?? this.answers,
    );
  }

  @override
  List<Object?> get props => [status, answers];
}
