import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String _read(String key, {String defaultValue = ''}) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) return defaultValue;
    return value;
  }

  static String get googleWebClientId =>
      _read('GOOGLE_WEB_CLIENT_ID');

  static String get fcmProjectId =>
      _read('FCM_PROJECT_ID');

  static String get fcmServiceAccountPath => _read(
        'FCM_SERVICE_ACCOUNT_PATH',
        defaultValue: 'assets/service_account.json',
      );

  static String get geminiFallbackApiKey =>
      _read('GEMINI_FALLBACK_API_KEY');
}
