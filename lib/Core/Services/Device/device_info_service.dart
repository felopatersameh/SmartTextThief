import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  static final DeviceInfoPlugin _plugin = DeviceInfoPlugin();

  /// Returns device info map for auth payload.
  /// Platform: android | ios
  /// manufacturer, model, brand, osVersion
  static Future<(Map<String, dynamic>, String)> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final android = await _plugin.androidInfo;
        return ({
          'platform': 'android',
          'manufacturer': android.manufacturer,
          'model': android.model,
          'brand': android.brand,
          'osVersion': '${android.version.release} (SDK ${android.version.sdkInt})',
          'device': android.device,
          'product': android.product,
        }, android.id);
      }
      if (Platform.isIOS) {
        final ios = await _plugin.iosInfo;
        return ({
          'platform': 'ios',
          'manufacturer': 'Apple',
          'model': ios.model,
          'brand': 'Apple',
          'osVersion': ios.systemVersion,
          'name': ios.name,
          'systemName': ios.systemName,
      },ios.identifierForVendor??"");
      }
    } catch (_) {}
    return ({
      'platform': Platform.operatingSystem,
      'osVersion': Platform.operatingSystemVersion,
    }, '');
  }
}
