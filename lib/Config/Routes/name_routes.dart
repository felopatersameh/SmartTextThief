class NameRoutes {
  static const String splash = '/';
  static const String login = 'login';
  static const String main = 'main';
}

extension PathStringExtension on String {
  String ensureWithSlash() => startsWith('/') ? this : '/$this';

  String removeSlash() => endsWith('/') ? substring(0, length - 1) : this;
}
