import 'package:flutter/services.dart';

class ScreenshotProtectionService {
  static const platform = MethodChannel('screenshot_protection');
  
  // Counter لعدد مرات Screenshot في iOS
  static int _iosScreenshotCount = 0;
  
  // Callback عند كشف Screenshot
  static Function()? _onScreenshotDetected;
  static Function()? _onSecondScreenshot;

  /// تفعيل الحماية للشاشة
  static Future<void> enableProtection({
    Function()? onFirstScreenshot,
    Function()? onSecondScreenshot,
  }) async {
    _iosScreenshotCount = 0;
    _onScreenshotDetected = onFirstScreenshot;
    _onSecondScreenshot = onSecondScreenshot;
    
    try {
      await platform.invokeMethod('enableSecureMode');
      
      platform.setMethodCallHandler(_handleMethodCall);
      
      print('🔒 Screenshot protection enabled');
    } catch (e) {
      print('Error enabling protection: $e');
    }
  }

  /// إلغاء الحماية عند الخروج من الشاشة
  static Future<void> disableProtection() async {
    try {
      await platform.invokeMethod('disableSecureMode');
      platform.setMethodCallHandler(null);
      _iosScreenshotCount = 0;
      print('🔓 Screenshot protection disabled');
    } catch (e) {
      print('Error disabling protection: $e');
    }
  }

  /// معالجة الرسائل من Native Code
  static Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onScreenshot') {
      _iosScreenshotCount++;
      
      print('📸 Screenshot detected! Count: $_iosScreenshotCount');
      
      if (_iosScreenshotCount == 1) {
        // المرة الأولى: تحذير
        _onScreenshotDetected?.call();
      } else if (_iosScreenshotCount >= 2) {
        // المرة الثانية: إنهاء الامتحان
        _onSecondScreenshot?.call();
      }
    }
  }

  /// Reset الـ counter (اختياري)
  static void resetCounter() {
    _iosScreenshotCount = 0;
  }
}