import '../../Utils/Models/exam_result_q_a.dart';

/// Result wrapper for exam generation
class ExamGenerationResultModel {
  final bool isSuccess;
  final List<ExamResultQA>? questions;
  final String? errorMessage;

  ExamGenerationResultModel._({
    required this.isSuccess,
    this.questions,
    this.errorMessage,
  });

  factory ExamGenerationResultModel.success(List<ExamResultQA> questions) {
    return ExamGenerationResultModel._(
      isSuccess: true,
      questions: questions,
    );
  }

  factory ExamGenerationResultModel.error(String message) {
    return ExamGenerationResultModel._(
      isSuccess: false,
      errorMessage: message,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'isSuccess': isSuccess,
      'questions': questions?.map((x) => x.toJson()).toList(),
      'errorMessage': errorMessage,
    };
  }
}
