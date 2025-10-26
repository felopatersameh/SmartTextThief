import '../../Core/Storage/Local/local_storage_keys.dart';
import '../../Core/Storage/Local/local_storage_service.dart';

class NameRoutes {
  static const String splash = '/';
  static const String login = 'login';
  // static const String main = 'main';

  static const String profile = 'in';
  static const String home = 'home';
  static const String subject = 'subjects';

  static const String subjectDetails = 's/';
  static const String createExam = 'create';
  static const String doExam = 'do/';
  static const String view = 'view';

  static final Map<String, String> titleAppBar = {
    profile: "profile",
    home: "home",
    subject: "Subjects",
    createExam: "Create Exam",
    subjectDetails: "Detail",
  };
}

extension PathStringExtension on String {
  String ensureWithSlash() => startsWith('/') ? this : '/$this';
  Future<String> ensureWithId() async {
    final id = (await LocalStorageService.getValue(
      LocalStorageKeys.id,
    )).toString().substring(0, 5);
    return id;
  }

  String removeSlash() => endsWith('/') ? substring(0, length - 1) : this;

  get titleAppBar => NameRoutes.titleAppBar[this]??"";
}
