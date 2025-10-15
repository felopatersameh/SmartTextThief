enum LevelExam {
  easy("easy"),
  meduim("meduim"),
  hard("hard");

  final String name;
  const LevelExam(this.name);

  static LevelExam fromString(String value) {
    return LevelExam.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LevelExam.meduim,
    );
  }
}

