enum UserType {
  st(value: "student"),
  te(value: "instructor"),
  ad(value: "admin"),
  non(value: "non");

  final String value;
  const UserType({required this.value});

  static UserType fromString(String value) {
    // if (normalized == 'instructor') {
    //   return UserType.te;
    // }
    return UserType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserType.non,
    );
  }
}
