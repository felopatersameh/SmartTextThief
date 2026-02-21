import 'package:smart_text_thief/Core/Utils/Models/questions_generated_model.dart';


/// Result wrapper for exam generation
class ExamGenerationResultModel {
  final bool isSuccess;
  final List<QuestionsGeneratedModel>? questions;
  final String? errorMessage;

  ExamGenerationResultModel._({
    required this.isSuccess,
    this.questions,
    this.errorMessage,
  });

  factory ExamGenerationResultModel.success(
      List<QuestionsGeneratedModel> questions) {
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
