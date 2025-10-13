enum UserType {
  st(value: "student"),
  te(value: "teacher"),
  ad(value: "admin"),
  non(value: "non");

  final String value;
  const UserType({required this.value});

  static UserType fromString(String value) {
    return UserType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserType.non,
    );
  }
}
