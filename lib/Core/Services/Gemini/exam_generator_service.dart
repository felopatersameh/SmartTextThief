import 'dart:developer';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';

import '../../../Features/CreateExam/data/models/information_file_model.dart';
import 'api_gemini.dart';
import '../../../Core/Services/Gemini/exam_generation_result_model.dart';
import '../../../Core/Services/Gemini/exam_prompt_generator.dart';
import '../../../Core/Services/Gemini/exam_response_parser.dart';
import '../../../Core/Services/Gemini/file_text_extractor.dart';
import '../../../Core/Utils/Enums/level_exam.dart';

class ExamGeneratorService {
  final ApiGemini _apiGemini;
  final FileTextExtractor _fileExtractor;
  static const int _maxEducationalTextChars = 2000;

  ExamGeneratorService({
    required String apiKey,
    required int maxOutputTokens,
    required double temperature,
    String modelName = AppConstants.defaultGeminiModel,
  })  : _apiGemini = ApiGemini(
          apiKey: apiKey,
          modelName: modelName,
          maxOutputTokens: maxOutputTokens,
          temperature: temperature,
        ),
        _fileExtractor = FileTextExtractor();

  Future<ExamGenerationResultModel> generateExamQuestions({
    String? manualText,
    List<InformationFileModel>? uploadedFiles,
    required LevelExam level,
    required String multipleChoiceCount,
    required String trueFalseCount,
    required String shortAnswerCount,
    required int examDurationMinutes,
    String? contentContext,
  }) async {
    try {
      final expectedQuestionsCount = (int.tryParse(multipleChoiceCount) ?? 0) +
          (int.tryParse(trueFalseCount) ?? 0) +
          (int.tryParse(shortAnswerCount) ?? 0);

      if (expectedQuestionsCount <= 0) {
        return ExamGenerationResultModel.error(
            'Please select at least one question.');
      }

      String educationalText;

      if (uploadedFiles != null && uploadedFiles.isNotEmpty) {
        educationalText = await _fileExtractor.extractAndCombine(uploadedFiles);

        if (!_fileExtractor.isTextSufficient(educationalText)) {
          return ExamGenerationResultModel.error(
              'The uploaded file does not contain enough readable educational content.');
        }
      } else if (manualText != null && manualText.trim().isNotEmpty) {
        educationalText = manualText;

        if (!_fileExtractor.isTextSufficient(educationalText)) {
          return ExamGenerationResultModel.error(
              'Please provide more educational content before generating the exam.');
        }
      } else {
        return ExamGenerationResultModel.error(
            'Please provide educational content (text or file).');
      }

      if (educationalText.length > _maxEducationalTextChars) {
        educationalText =
            educationalText.substring(0, _maxEducationalTextChars);
      }

      // Extra smart validation (roadmap detection)
      if (_isTopicListOnly(educationalText)) {
        return ExamGenerationResultModel.error(
            'The content appears to be only a list of topics. Please provide detailed explanations or paragraphs.');
      }

      final prompt = ExamPromptGenerator.generatePrompt(
        educationalText: educationalText,
        level: level,
        multipleChoiceCount: multipleChoiceCount,
        trueFalseCount: trueFalseCount,
        shortAnswerCount: shortAnswerCount,
        examDurationMinutes: examDurationMinutes,
        contentContext: contentContext,
      );

      final response = await _apiGemini.generateContent(prompt);
      log("response usageMetadata candidatesTokenCount :: ${response.usageMetadata?.candidatesTokenCount} ");
      log("response usageMetadata promptTokenCount :: ${response.usageMetadata?.promptTokenCount} ");
      log("response usageMetadata totalTokenCount :: ${response.usageMetadata?.totalTokenCount} ");
      // log("response promptFeedback blockReason :: ${response.promptFeedback?.blockReason} ");
      // log("response promptFeedback blockReasonMessage :: ${response.promptFeedback?.blockReasonMessage} ");
      // log("response promptFeedback safetyRatings :: ${response.promptFeedback?.safetyRatings} ");
      final finishReason = response.candidates.isNotEmpty
          ? response.candidates.first.finishReason
          : null;

      final responseText = response.text ?? "";
      log("responseText :: $responseText");
      if (finishReason == FinishReason.maxTokens) {
        return ExamGenerationResultModel.error(
            'The generated exam was too long and got cut off. Please reduce the number of questions or shorten the content.');
      }

      if (responseText.trim().isEmpty) {
        return ExamGenerationResultModel.error(
            'No questions were generated. Please try again.');
      }


      final questions = ExamResponseParser.parseQuestions(responseText);

      if (questions.length != expectedQuestionsCount) {
        return ExamGenerationResultModel.error(
            'The generated exam did not match the requested number of questions. Please adjust the content or question count.');
      }

      if (!ExamResponseParser.validateQuestions(questions)) {
        return ExamGenerationResultModel.error(
            'Some generated questions were invalid. Please try again.');
      }

      return ExamGenerationResultModel.success(questions);
    } catch (e) {
      log("error Generated :$e");
      return ExamGenerationResultModel.error(
          'An unexpected error occurred while generating the exam. Please try again.');
    }   
  }

  // Detect if content is just bullet list / roadmap
  bool _isTopicListOnly(String text) {
    final lines = text.split('\n');
    int shortLines = 0;

    for (var line in lines) {
      if (line.trim().length < 30) {
        shortLines++;
      }
    }

    return shortLines > (lines.length * 0.6);
  }
}
