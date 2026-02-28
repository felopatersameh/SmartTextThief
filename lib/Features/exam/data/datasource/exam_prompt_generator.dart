import 'package:smart_text_thief/Features/exam/domain/enums/exam_question_type.dart';
import 'package:smart_text_thief/Features/exam/domain/enums/level_exam.dart';

class ExamPromptGenerator {
  static String generatePrompt({
    required String educationalText,
    required LevelExam level,
    required String multipleChoiceCount,
    required String trueFalseCount,
    required String shortAnswerCount,
    required int examDurationMinutes,
    String? contentContext,
  }) {
    return '''
Generate exam questions as a VALID JSON array ONLY.

Educational Content:
$educationalText

${contentContext != null ? "Main Focus: $contentContext" : ""}

Specifications:
- MCQ: $multipleChoiceCount
- True/False: $trueFalseCount
- Short Answer: $shortAnswerCount
- Difficulty Level: ${level.name}
- Duration: $examDurationMinutes minutes

STRICT RULES:
1. Use ONLY the educational content above.
2. If Main Focus is provided, questions MUST focus primarily on it.
3. Do NOT introduce external knowledge.
4. Generate EXACTLY the specified number for each type.
5. Difficulty must match ${level.name}.
6. Match the language of the content.
7. Return ONLY a JSON array (no text, no markdown, no explanation).

IMPORTANT STRUCTURE RULES:
- "${ExamQuestionType.multipleChoice.value}" MUST contain exactly 4 options.
- "${ExamQuestionType.trueFalse.value}" MUST contain exactly 2 options.
- "${ExamQuestionType.shortAnswer.value}" MUST have an empty options array [].
- "studentAnswer" must always be an empty string "".
- IDs must be sequential: Q1, Q2, Q3...

JSON Structure Examples:

Multiple Choice Example:
{
"id": "Q1",
"type": "${ExamQuestionType.multipleChoice.value}",
"text": "Question text",
"options": [
  "Option A",
  "Option B",
  "Option C",
  "Option D"
],
"correctAnswer": "Option A",
"studentAnswer": ""
}

True/False Example:
{
"id": "Q2",
"type": "${ExamQuestionType.trueFalse.value}",
"text": "Statement text",
"options": ["True", "False"],
"correctAnswer": "True",
"studentAnswer": ""
}

Short Answer Example:
{
"id": "Q3",
"type": "${ExamQuestionType.shortAnswer.value}",
"text": "Question text",
"options": [],
"correctAnswer": "Expected answer",
"studentAnswer": ""
}

Generate ALL questions in one single JSON array and do NOT stop until all required questions are generated.
''';
  }
}
