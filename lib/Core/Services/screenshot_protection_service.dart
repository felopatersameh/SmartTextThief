import 'package:no_screenshot/no_screenshot.dart';

class ScreenshotProtectionService {
  static final NoScreenshot _noScreenshot = NoScreenshot.instance;
  static int _activeProtectionRequests = 0;

  static Future<void> enableProtection() async {
    _activeProtectionRequests++;
    if (_activeProtectionRequests > 1) return;

    try {
      await _noScreenshot.screenshotOff();
    } catch (_) {}
  }

  static Future<void> disableProtection() async {
    if (_activeProtectionRequests == 0) return;

    _activeProtectionRequests--;
    if (_activeProtectionRequests > 0) return;

    try {
      await _noScreenshot.screenshotOn();
    } catch (_) {}
  }

  static void reset() {
    _activeProtectionRequests = 0;
  }
}
