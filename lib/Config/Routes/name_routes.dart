import '../../Core/Storage/Local/local_storage_keys.dart';
import '../../Core/Storage/Local/local_storage_service.dart';

class NameRoutes {
  static const String splash = '/';
  static const String login = 'login';

  static const String profile = 'in';
  static const String notification = 'notifications';
  static const String subject = 'subjects';

  static const String subjectDetails = 's/';
  static const String createExam = 'create';
  static const String doExam = 'do/';
  static const String view = 'view';
  static const String result = 'result';

  static final Map<String, String> titleAppBar = {
    profile: "profile",
    notification: "notifications",
    subject: "Subjects",
    createExam: "Create Exam",
    subjectDetails: "Detail",
    doExam: "Exam Live",
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

  String get titleAppBar => NameRoutes.titleAppBar[this] ?? "";
}
