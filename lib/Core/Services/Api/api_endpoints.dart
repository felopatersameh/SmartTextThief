class ApiEndpoints {
  static var baseUrl = 'https://apitextthief-production.up.railway.app/';

  static const String authGoogle = 'auth/google';
  static const String userProfile = 'v1/user';
  static const String userDashboard = 'v1/user/dashboard';
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
  static String subjectGetAnalytics(String id) => 'v1/subject/$id/analytics';
  static String subjectStartExam(String id, String idExam) =>
      'v1/subject/$id/exam/$idExam/start_exam';
  static String subjectSubmitExam(String id, String idExam) =>
      'v1/subject/$id/exam/$idExam/submit_exam';
  static String subjectGetResult(String id, String examId) =>
      'v1/subject/$id/exam/$examId/get_result';
  static const String notifications = 'v1/notifications';
  static const String notificationsRead = 'v1/notifications/read';
  static const String notificationsOpen = 'v1/notifications/open';
}
