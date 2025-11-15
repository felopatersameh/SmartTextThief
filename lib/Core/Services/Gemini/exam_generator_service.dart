import '../../../Features/Exams/Persentation/widgets/upload_option_section.dart';
import 'api_gemini.dart';
import '../../../Core/Services/Gemini/exam_generation_result_model.dart';
import '../../../Core/Services/Gemini/exam_prompt_generator.dart';
import '../../../Core/Services/Gemini/exam_response_parser.dart';
import '../../../Core/Services/Gemini/file_text_extractor.dart';
import '../../../Core/Utils/Enums/level_exam.dart';


class ExamGeneratorService {
  final ApiGemini _apiGemini;
  final FileTextExtractor _fileExtractor;

  ExamGeneratorService()
    : _apiGemini = ApiGemini(),
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
  }) async {
    try {
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

      // Step 2: Generate prompt
      final prompt = ExamPromptGenerator.generatePrompt(
        educationalText: educationalText,
        level: level,
        multipleChoiceCount: multipleChoiceCount,
        trueFalseCount: trueFalseCount,
        shortAnswerCount: shortAnswerCount,
      );

      // Step 3: Send to Gemini API
      final response = await _apiGemini.generateContent(prompt);

      // Step 4: Parse response to questions
      final questions = ExamResponseParser.parseQuestions(response);

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
