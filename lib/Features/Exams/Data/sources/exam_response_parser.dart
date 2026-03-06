import 'dart:convert';

import 'package:smart_text_thief/Features/Exams/shared/Enums/exam_question_type.dart';

import '../../shared/Models/Results/question_model.dart';

class ExamResponseParser {
  static List<QuestionModel> parseQuestions(String jsonResponse) {
    try {
      final cleanedJson = _cleanJsonResponse(jsonResponse);
      final parsed = jsonDecode(cleanedJson);

      late final List<dynamic> questionsList;
      if (parsed is List) {
        questionsList = parsed;
      } else if (parsed is Map<String, dynamic>) {
        if (parsed.containsKey('questions')) {
          final rawQuestions = parsed['questions'];
          if (rawQuestions is! List) {
            throw Exception('questions is not a list');
          }
          questionsList = rawQuestions;
        } else if (parsed.containsKey('data')) {
          final rawData = parsed['data'];
          if (rawData is! List) {
            throw Exception('data is not a list');
          }
          questionsList = rawData;
        } else {
          throw Exception('JSON does not contain questions array');
        }
      } else {
        throw Exception('Invalid JSON format');
      }

      return questionsList
          .whereType<Map>()
          .map((json) => QuestionModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (_) {
      rethrow;
    }
  }

  static String _cleanJsonResponse(String response) {
    var cleaned = response.trim();

    cleaned = cleaned.replaceAll(RegExp(r'^```json\s*', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'^```\s*', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s*```$', multiLine: true), '');
    cleaned = cleaned.trim();

    final jsonStart = cleaned.indexOf('[');
    final jsonObjectStart = cleaned.indexOf('{');

    if (jsonStart != -1 &&
        (jsonObjectStart == -1 || jsonStart < jsonObjectStart)) {
      final jsonEnd = cleaned.lastIndexOf(']');
      if (jsonEnd != -1) {
        cleaned = cleaned.substring(jsonStart, jsonEnd + 1);
      }
    } else if (jsonObjectStart != -1) {
      final jsonEnd = cleaned.lastIndexOf('}');
      if (jsonEnd != -1) {
        cleaned = cleaned.substring(jsonObjectStart, jsonEnd + 1);
      }
    }

    return cleaned.trim();
  }

  static bool validateQuestions(List<QuestionModel> questions) {
    if (questions.isEmpty) return false;

    for (final question in questions) {
      if (question.id.isEmpty ||
          question.type.isEmpty ||
          question.text.isEmpty ||
          question.correctAnswer.isEmpty) {
        return false;
      }

      if (!ExamQuestionType.isValid(question.type)) {
        return false;
      }

      final questionType = ExamQuestionType.fromString(question.type);
      if (questionType == ExamQuestionType.multipleChoice &&
          question.options?.length != 4) {
        return false;
      }
      if (questionType == ExamQuestionType.trueFalse &&
          question.options?.length != 2) {
        return false;
      }
    }

    return true;
  }
}
