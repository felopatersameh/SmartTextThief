import '../../Utils/Enums/level_exam.dart';

/// Prompt generator for different scenarios
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
    // final totalQuestions = int.parse(multipleChoiceCount) +
    //     int.parse(trueFalseCount) +
    //     int.parse(shortAnswerCount);

    // final timePerQuestion =
    //     (examDurationMinutes / totalQuestions).toStringAsFixed(1);

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
- "multiple_choice" MUST contain exactly 4 options.
- "true_false" MUST contain exactly 2 options.
- "short_answer" MUST have an empty options array [].
- "studentAnswer" must always be an empty string "".
- IDs must be sequential: Q1, Q2, Q3...

JSON Structure Examples:

Multiple Choice Example:
{
"id": "Q1",
"type": "multiple_choice",
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
"type": "true_false",
"text": "Statement text",
"options": ["True", "False"],
"correctAnswer": "True",
"studentAnswer": ""
}

Short Answer Example:
{
"id": "Q3",
"type": "short_answer",
"text": "Question text",
"options": [],
"correctAnswer": "Expected answer",
"studentAnswer": ""
}

Generate ALL questions in one single JSON array and do NOT stop until all required questions are generated.
''';
//     return '''
// You are an expert educational assessment creator. Generate exam questions in JSON format based STRICTLY and ONLY on the provided educational content below.

// **Educational Content:**
// $educationalText

// ${contentContext != null ? '''**Content Context:** $contentContext

// **CRITICAL - Context Adherence:**
// - This content is EXCLUSIVELY about: $contentContext
// - DO NOT mix, compare, or reference ANY other context, belief system, or external material
// - Stay strictly within the boundaries of: $contentContext
// - All questions and answers must align with $contentContext ONLY
// - If the provided educational content doesn't cover a topic, DO NOT create questions about it

// ''' : ''}

// **Language Requirements:**
// - Detect the language of the educational content above
// - Generate ALL questions, options, and answers in the SAME language as the educational content
// - If the content is in Arabic, return everything in Arabic
// - If the content is in English, return everything in English
// - Maintain consistency in language throughout the entire JSON
// - Do NOT mix languages unless explicitly requested in the content context

// **Exam Specifications:**
// - Multiple Choice Questions: $multipleChoiceCount
// - True/False Questions: $trueFalseCount
// - Short Answer Questions: $shortAnswerCount
// - Total Questions: $totalQuestions
// - Exam Duration: $examDurationMinutes minutes
// - Time per Question: approximately $timePerQuestion minutes
// - Difficulty Level: ${level.name}

// **CRITICAL RULES - DO NOT VIOLATE:**
// 1. Create questions ONLY from the educational content provided above
// 2. DO NOT add questions from your own knowledge or external sources
// 3. DO NOT exceed the specified number of questions for each type
// 4. Each question must be answerable within ~$timePerQuestion minutes
// 5. Distribute difficulty evenly across all questions based on ${level.name} level
// 6. Balance time allocation: ensure all questions can be completed within $examDurationMinutes minutes total

// **Question Time Guidelines:**
// - Multiple Choice: ~${(examDurationMinutes / totalQuestions * 0.8).toStringAsFixed(1)} minutes each
// - True/False: ~${(examDurationMinutes / totalQuestions * 0.6).toStringAsFixed(1)} minutes each
// - Short Answer: ~${(examDurationMinutes / totalQuestions * 1.4).toStringAsFixed(1)} minutes each

// **JSON Output Requirements:**
// 1. Return ONLY a valid JSON array
// 2. NO explanations, comments, or additional text
// 3. NO markdown code blocks or formatting
// 4. Start directly with [ and end with ]

// **Required JSON Structure:**
// [
//   {
//     "id": "Q1",
//     "type": "multiple_choice",
//     "text": "Question text from provided content only",
//     "options":
//     [
//         { "id": "o1", "choice": "3" },
//         { "id": "o2", "choice": "4" },
//         { "id": "o3", "choice": "5" }
//     ],
//     "correctAnswer": "Option A",
//     "studentAnswer": "",
//   },
//   {
//     "id": "Q2",
//     "type": "true_false",
//     "text": "Statement from provided content only",
//     "options": ["True", "False"],
//     "correctAnswer": "True",
//     "studentAnswer": "",
//   },
//   {
//     "id": "Q3",
//     "type": "short_answer",
//     "text": "Question from provided content only",
//     "options": [],
//     "correctAnswer": "Expected answer based on provided content",
//     "studentAnswer": "",
//   }
// ]

// **Field Requirements:**
// - id: Sequential (Q1, Q2, Q3, ..., Q$totalQuestions)
// - type: MUST be exactly "multiple_choice", "true_false", or "short_answer"
// - text: Derived ONLY from the educational content above
// - options:
//   * multiple_choice: Exactly 4 options (plausible distractors from content)
//   * true_false: Exactly ["True", "False"] OR ["صح", "خطأ"] based on content language
//   * short_answer: Empty array []
// - correctAnswer: The correct answer from the provided content
// - studentAnswer: Always empty string ""

// **STRICT REMINDER:**
// - Question Count: EXACTLY $multipleChoiceCount multiple choice + $trueFalseCount true/false + $shortAnswerCount short answer
// - Source: ONLY the educational content provided above
// - Time: Each question appropriate for ~$timePerQuestion minutes
// - Level: Consistent ${level.name} difficulty throughout
// - Language: Match the language of the educational content exactly

// Generate the JSON array now (NO additional text, start with [):
// ''';
  }
}
