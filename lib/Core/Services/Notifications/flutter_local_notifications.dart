import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../Utils/Enums/notification_type.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static void Function(String? payload)? _onNotificationTap;

  static Future<void> initialize({
    void Function(String? payload)? onNotificationTap,
  }) async {
    if (onNotificationTap != null) {
      _onNotificationTap = onNotificationTap;
    }
    if (_initialized) return;

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        _onNotificationTap?.call(response.payload);
      },
    );

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final launchDetails = await _notificationsPlugin
        .getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _onNotificationTap?.call(launchDetails?.notificationResponse?.payload);
    }

    _initialized = true;
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }
    final type = NotificationType.fromString(title);
    final androidDetails = AndroidNotificationDetails(
      type.channelId,
      type.channelName,
      channelDescription: '${type.title} notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/launcher_icon',
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: type.title,
        summaryText: body,
      ),
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: type.title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }
}
