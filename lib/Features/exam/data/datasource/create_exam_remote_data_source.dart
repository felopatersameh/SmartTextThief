import 'dart:developer';

import 'package:smart_text_thief/Features/exam/domain/enums/level_exam.dart';
import '../dto/responses/exam_generation_result_model.dart';
import 'exam_generator_service.dart';
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
      maxOutputTokens: calculateMaxTokensFromRealUsage(
        avgTokensPerQuestion: 200,
        questionCount: ((int.tryParse(multipleChoiceCount)?.toInt() ?? 0) +
            (int.tryParse(shortAnswerCount)?.toInt() ?? 0) +
            (int.tryParse(trueFalseCount)?.toInt() ?? 0)),
      ),
      temperature: temperature(level),
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

double temperature(LevelExam level) => switch (level) {
      LevelExam.easy => 0.2,
      LevelExam.normal => 0.25,
      LevelExam.hard => 0.35,
    };
int calculateMaxTokensFromRealUsage({
  required int questionCount,
  required int avgTokensPerQuestion,
}) {
  int base = questionCount * avgTokensPerQuestion;
  final max = (base * 1.7).toInt();
  log("Max Token ::$max ");
  return max; 
}

