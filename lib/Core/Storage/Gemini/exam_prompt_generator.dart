import 'package:smart_text_thief/Core/Utils/Enums/level_exam.dart';

/// Prompt generator for different scenarios
class ExamPromptGenerator {
  static String generatePrompt({
    required String educationalText,
    required LevelExam level,
    required String multipleChoiceCount,
    required String trueFalseCount,
    required String shortAnswerCount,
  }) {
    return '''
You are an expert educational assessment creator. Generate exam questions in JSON format based on the provided educational content.

**Educational Content:**
$educationalText

**Requirements:**
- Multiple Choice Questions: $multipleChoiceCount
- True/False Questions: $trueFalseCount
- Short Answer Questions: $shortAnswerCount
- Difficulty Level: ${level.name}
- Total Questions: ${multipleChoiceCount + trueFalseCount + shortAnswerCount}

**Important Instructions:**
1. Return ONLY a valid JSON array, no additional text or explanation
2. Each question must follow this exact structure
3. Questions must be based strictly on the provided educational content
4. Ensure variety in topics and difficulty
5. Make questions clear and unambiguous

**JSON Format (Return EXACTLY this structure):**
```json
[
  {
    "questionId": "Q1",
    "questionType": "multiple_choice",
    "questionText": "What is the main concept discussed?",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctAnswer": "Option A",
    "studentAnswer": "",
    "score": null
  },
  {
    "questionId": "Q2",
    "questionType": "true_false",
    "questionText": "The statement is correct",
    "options": ["True", "False"],
    "correctAnswer": "True",
    "studentAnswer": "",
    "score": null
  },
  {
    "questionId": "Q3",
    "questionType": "short_answer",
    "questionText": "Explain the concept",
    "options": [],
    "correctAnswer": "Expected detailed answer",
    "studentAnswer": "",
    "score": null
  }
]
```

**Field Requirements:**
- questionId: Sequential (Q1, Q2, Q3, ...)
- questionType: MUST be one of: "multiple_choice", "true_false", "short_answer"
- questionText: Clear question based on content
- options: 
  * multiple_choice: Exactly 4 options
  * true_false: Exactly ["True", "False"]
  * short_answer: Empty array []
- correctAnswer: The correct answer
- studentAnswer: Always empty string ""
- score: Always null

Generate the JSON array now:
''';
  }
}
