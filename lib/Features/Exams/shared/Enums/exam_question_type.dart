enum ExamQuestionType {
  multipleChoice(value: 'multiple_choice'),
  trueFalse(value: 'true_false'),
  shortAnswer(value: 'short_answer');

  final String value;
  const ExamQuestionType({required this.value});

  static ExamQuestionType fromString(String value) {
    return ExamQuestionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ExamQuestionType.shortAnswer,
    );
  }

  static bool isValid(String value) {
    return ExamQuestionType.values.any((e) => e.value == value);
  }
}
