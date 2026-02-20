class ApiEndpoints {
  static var baseUrl = 'http://192.168.1.12:8080/';

  static const String authGoogle = 'auth/google';
  static const String userProfile = 'v1/user';
  static const String userLogout = 'v1/user/logout';
  static const String userSubmitRole = 'v1/user/submitRole';
  static const String userRemove = 'v1/user/remove';

  static const String subjects = 'v1/subject';
  static const String subjectCreate = 'v1/subject/create';
  static const String subjectJoin = 'v1/subject/join';

  static String subjectUpdateStatus(String id) =>
      'v1/subject/$id/update_status';
  static String subjectRemove(String id) => 'v1/subject/$id/remove';
  static String subjectCreateExam(String id) => 'v1/subject/$id/create_exam';
  static String subjectGetExams(String id) => 'v1/subject/$id/get_exams';
}
  