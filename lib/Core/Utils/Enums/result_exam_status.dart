enum ResultExamStatus {
  running('running'),
  finished('finished'),
  timeExpired('time_expired'),
  connectionLost('connection_lost'),
  disposed('disposed'),
  unknown('unknown'),
  els('else');

  final String value;

  const ResultExamStatus(this.value);

  static ResultExamStatus fromString(String? value) {
    if (value == null) return ResultExamStatus.els;

    return ResultExamStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ResultExamStatus.els,
    );
  }
}
