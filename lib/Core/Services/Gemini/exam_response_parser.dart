import 'dart:convert';
import '../../Utils/Models/exam_result_q_a.dart';

/// Parser for AI responses
class ExamResponseParser {
  static List<ExamResultQA> parseQuestions(String jsonResponse) {
    try {
      String cleanedJson = _cleanJsonResponse(jsonResponse);
      final dynamic parsed = jsonDecode(cleanedJson);
      
      List<dynamic> questionsList;
      
      if (parsed is List) {
        questionsList = parsed;
      } else if (parsed is Map<String, dynamic>) {
        if (parsed.containsKey('questions')) {
          questionsList = parsed['questions'] as List;
        } else if (parsed.containsKey('data')) {
          questionsList = parsed['data'] as List;
        } else {
          throw Exception('JSON does not contain questions array');
        }
      } else {
        throw Exception('Invalid JSON format');
      }
      
      return questionsList
          .map((json) => ExamResultQA.fromJson(json as Map<String, dynamic>))
          .toList();
          
    } catch (e) {
      // log('Error parsing questions: $e');
      // log('Response was: $jsonResponse');
      rethrow;
    }
  }

  static String _cleanJsonResponse(String response) {
    String cleaned = response.trim();
    
    // Remove markdown code blocks
    cleaned = cleaned.replaceAll(RegExp(r'^```json\s*', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'^```\s*', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s*```$', multiLine: true), '');
    cleaned = cleaned.trim();
    
    // Find JSON array or object
    final jsonStart = cleaned.indexOf('[');
    final jsonObjectStart = cleaned.indexOf('{');
    
    if (jsonStart != -1 && (jsonObjectStart == -1 || jsonStart < jsonObjectStart)) {
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

  static bool validateQuestions(List<ExamResultQA> questions) {
    if (questions.isEmpty) return false;
    
    for (var q in questions) {
      if (q.questionId.isEmpty || 
          q.questionType.isEmpty || 
          q.questionText.isEmpty ||
          q.correctAnswer.isEmpty) {
        return false;
      }
      
      if (!['multiple_choice', 'true_false', 'short_answer'].contains(q.questionType)) {
        return false;
      }
      
      if (q.questionType == 'multiple_choice' && q.options.length != 4) {
        return false;
      }
      if (q.questionType == 'true_false' && q.options.length != 2) {
        return false;
      }
    }
    
    return true;
  }
}
