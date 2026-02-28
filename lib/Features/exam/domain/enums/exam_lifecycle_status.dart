enum ExamStatus {
  available('available'), // (is live) [[but]] (not do it ) =>
  pendingTime('pendingTime'),// (is live and do it) [[but]] (exam's time is not finishing yet)
  time('time'), // (is don't be live and do it and exam's time is finishing )
  instructor('instructor'), // is creator person
  unknown('unknown'); // not working now

  const ExamStatus(this.value);

  final String value;

  static ExamStatus fromString(String value) {
    return ExamStatus.values.firstWhere(
      (element) => element.value == value,
      orElse: () => ExamStatus.unknown,
    );
  }

}
