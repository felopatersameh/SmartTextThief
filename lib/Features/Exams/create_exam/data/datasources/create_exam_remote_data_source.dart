import 'package:smart_text_thief/Core/Services/Gemini/exam_generator_service.dart';
import 'package:smart_text_thief/Core/Utils/Enums/level_exam.dart';

import '../../../../../../Core/Services/Gemini/exam_generation_result_model.dart';
import '../models/information_file_model.dart';

class CreateExamRemoteDataSource {
  Future<ExamGenerationResultModel> generateExamQuestions({
    required String apiKey,
    required String modelName,
    required LevelExam level,
    required String multipleChoiceCount,
    required String trueFalseCount,
    required String shortAnswerCount,
    required List<InformationFileModel> uploadedFiles,
    required int examDurationMinutes,
    required String contentContext,
    required String manualText,
  }) {
    return ExamGeneratorService(
      apiKey: apiKey,
      modelName: modelName,
    ).generateExamQuestions(
      level: level,
      multipleChoiceCount: multipleChoiceCount,
      trueFalseCount: trueFalseCount,
      shortAnswerCount: shortAnswerCount,
      uploadedFiles: uploadedFiles,
      examDurationMinutes: examDurationMinutes,
      contentContext: contentContext,
      manualText: manualText,
    );
  }
}
