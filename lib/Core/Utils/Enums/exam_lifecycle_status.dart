enum ExamStatus {
  available('available'),
  pendingTime('pendingTime'),
  time('time'),
  instructor('instructor'),
  unknown('unknown');

  const ExamStatus(this.value);

  final String value;

  static ExamStatus fromString(String value) {
    return ExamStatus.values.firstWhere(
      (element) => element.value == value,
      orElse: () => ExamStatus.unknown,
    );
  }
}
