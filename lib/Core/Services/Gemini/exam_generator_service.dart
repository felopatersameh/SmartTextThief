import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../Features/Exams/create_exam/data/models/information_file_model.dart';
import 'api_gemini.dart';
import '../../../Core/Services/Gemini/exam_generation_result_model.dart';
import '../../../Core/Services/Gemini/exam_prompt_generator.dart';
import '../../../Core/Services/Gemini/exam_response_parser.dart';
import '../../../Core/Services/Gemini/file_text_extractor.dart';
import '../../../Core/Utils/Enums/level_exam.dart';

class ExamGeneratorService {
  final ApiGemini _apiGemini;
  final FileTextExtractor _fileExtractor;
  static const int _maxEducationalTextChars = 20000;

  ExamGeneratorService({required String apiKey})
      : _apiGemini = ApiGemini(apiKey: apiKey),
        _fileExtractor = FileTextExtractor();

  /// Main method: Generate exam questions
  /// Returns: List of ExamResultQA
  Future<ExamGenerationResultModel> generateExamQuestions({
    // Content source
    String? manualText,
    List<InformationFileModel>? uploadedFiles,

    // Question settings

    required LevelExam level,
    required String multipleChoiceCount,
    required String trueFalseCount,
    required String shortAnswerCount,
    required int examDurationMinutes,
    String? contentContext,
  }) async {
    try {
      final expectedQuestionsCount =
          (int.tryParse(multipleChoiceCount) ?? 0) +
              (int.tryParse(trueFalseCount) ?? 0) +
              (int.tryParse(shortAnswerCount) ?? 0);
      if (expectedQuestionsCount <= 0) {
        return ExamGenerationResultModel.error(
          'Invalid questions count. Please choose at least one question.',
        );
      }

      // Step 1: Get educational text
      String educationalText;

      if (uploadedFiles != null && uploadedFiles.isNotEmpty) {
        // Extract text from files
        educationalText = await _fileExtractor.extractAndCombine(uploadedFiles);

        if (!_fileExtractor.isTextSufficient(educationalText)) {
          return ExamGenerationResultModel.error(
            'Insufficient text extracted from files. Please check your files.',
          );
        }
      } else if (manualText != null && manualText.trim().isNotEmpty) {
        // Use manual text
        educationalText = manualText;

        if (!_fileExtractor.isTextSufficient(educationalText)) {
          return ExamGenerationResultModel.error(
            'Please provide more educational content (at least 50 words)',
          );
        }
      } else {
        return ExamGenerationResultModel.error(
          'Please provide educational content (text or files)',
        );
      }

      // Keep prompt size bounded to reduce model truncation/errors.
      if (educationalText.length > _maxEducationalTextChars) {
        educationalText = educationalText.substring(0, _maxEducationalTextChars);
      }

      // Step 2: Generate prompt
      final prompt = ExamPromptGenerator.generatePrompt(
          educationalText: educationalText,
          level: level,
          multipleChoiceCount: multipleChoiceCount,
          trueFalseCount: trueFalseCount,
          shortAnswerCount: shortAnswerCount,
          examDurationMinutes: examDurationMinutes,
          contentContext: contentContext);

      // Step 3: Send to Gemini API
      final response = await _apiGemini.generateContent(prompt);
      final finishReason = response.candidates.isNotEmpty
          ? response.candidates.first.finishReason
          : null;
      final responseText = response.text ?? "";

      if (finishReason == FinishReason.maxTokens) {
        return ExamGenerationResultModel.error(
          'Generated output was cut off (max tokens reached). Reduce question count/content size and try again.',
        );
      }
      if (responseText.trim().isEmpty) {
        return ExamGenerationResultModel.error(
          'No valid response generated. Please try again.',
        );
      }

      // Step 4: Parse response to questions
      final questions = ExamResponseParser.parseQuestions(responseText);

      if (questions.length != expectedQuestionsCount) {
        return ExamGenerationResultModel.error(
          'Generated ${questions.length} question(s), expected $expectedQuestionsCount. Please try again.',
        );
      }

      // Step 5: Validate questions
      if (!ExamResponseParser.validateQuestions(questions)) {
        return ExamGenerationResultModel.error(
          'Generated questions failed validation. Please try again.',
        );
      }

      // Step 6: Return success result
      return ExamGenerationResultModel.success(questions);
    } catch (e) {
      // log('Error in generateExamQuestions: $e');
      return ExamGenerationResultModel.error(
        'Error generating questions: ${e.toString()}',
      );
    }
  }
}
