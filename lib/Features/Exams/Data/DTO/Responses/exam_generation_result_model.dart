
import '../../../shared/Models/Results/question_model.dart';

class ExamGenerationResultModel {
  final bool isSuccess;
  final List<QuestionModel>? questions;
  final String? errorMessage;

  ExamGenerationResultModel._({
    required this.isSuccess,
    this.questions,
    this.errorMessage,
  });

  factory ExamGenerationResultModel.success(
    List<QuestionModel> questions,
  ) {
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
      'questions': questions?.map((question) => question.toJson()).toList(),
      'errorMessage': errorMessage,
    };
  }
}
