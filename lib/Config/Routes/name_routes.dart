
class NameRoutes {
  static const String splash = '/';
  static const String login = 'login';
  static const String chooseRole = 'choose-role';

  static const String profile = 'in';
  static const String notification = 'notifications';
  static const String subject = 'subjects';

  static const String subjectDetails = 's/';
  static const String createExam = 'create';
  static const String doExam = 'do/';
  static const String view = 'view';
  static const String result = 'result';

  static const String about = 'about';
  static const String help = 'help';
  static const String dashboard = 'dashboard';

  static final Map<String, String> titleAppBar = {
    profile: "profile",
    notification: "Notifications",
    subject: "Subjects",
    createExam: "Create Exam",
    subjectDetails: "Detail",
    doExam: "Exam Live",
    about: "About Smart Text Thief",
    help: "Help & Support",
    dashboard: "Dashboard",
  };
}

extension PathStringExtension on String {
  String ensureWithSlash() => startsWith('/') ? this : '/$this';
  // Future<String> ensureWithId() async {
  //   final id = (await LocalStorageService.getValue(
  //     LocalStorageKeys.id,
  //   ))
  //       .toString()
  //       .substring(0, 5);
  //   return id;
  // }

  String removeSlash() => endsWith('/') ? substring(0, length - 1) : this;

  String get titleAppBar => NameRoutes.titleAppBar[this] ?? "";
}
