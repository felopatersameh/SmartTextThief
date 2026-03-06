enum StudentResultLevel {
  excellent('excellent'),
  veryGood('very_good'),
  good('good'),
  pass('pass'),
  fail('fail');

  const StudentResultLevel(this.value);

  final String value;

  static StudentResultLevel fromScore({
    required int degree,
    required int total,
  }) {
    if (total <= 0) return StudentResultLevel.fail;
    final ratio = degree / total;

    if (ratio >= 0.9) return StudentResultLevel.excellent;
    if (ratio >= 0.8) return StudentResultLevel.veryGood;
    if (ratio >= 0.7) return StudentResultLevel.good;
    if (ratio >= 0.5) return StudentResultLevel.pass;
    return StudentResultLevel.fail;
  }
}

extension StudentResultLevelX on StudentResultLevel {
  String get label {
    switch (this) {
      case StudentResultLevel.excellent:
        return 'Excellent';
      case StudentResultLevel.veryGood:
        return 'Very Good';
      case StudentResultLevel.good:
        return 'Good';
      case StudentResultLevel.pass:
        return 'Pass';
      case StudentResultLevel.fail:
        return 'Fail';
    }
  }
}
