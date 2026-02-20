import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';

import '../../../Config/env_config.dart';
import '../../Utils/Enums/data_key.dart';
import 'flutter_local_notifications.dart';
import 'notification_model.dart';

class NotificationServices {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final Dio _dio = Dio();
  static final StreamController<NotificationModel> _notificationsController =
      StreamController<NotificationModel>.broadcast();

  static Function(bool)? onMessageOpenedAppCallback;
  static Function(RemoteMessage)? onMessageCallback;

  static Stream<NotificationModel> get notificationsStream =>
      _notificationsController.stream;

  static Future<void> initFCM() async {
    await LocalNotificationService.initialize();
    await _firebaseMessaging.requestPermission();

    // final tokenFCM = await _firebaseMessaging.getToken();
    // final tokenIn = await LocalStorageService.getValue(
    //   LocalStorageKeys.tokenFCM,
    //   defaultValue: null,
    // );

    // if (tokenFCM != null &&
    //     (tokenIn == null || tokenIn.toString() != tokenFCM)) {
    //   await LocalStorageService.setValue(LocalStorageKeys.tokenFCM, tokenFCM);
    // }

    FirebaseMessaging.onMessageOpenedApp.listen((onData) {
      final message = NotificationModel.fromJson(onData.data);
      _emitNotification(message);
      onMessageOpenedAppCallback?.call(message.topicId.isNotEmpty);
    });

    FirebaseMessaging.onMessage.listen((onData) async {
      final message = NotificationModel.fromJson(onData.data);
      _emitNotification(message);

      await LocalNotificationService.showNotification(
        title: message.title,
        body: message.body,
      );

      onMessageCallback?.call(onData);
    });
  }

  static Future<void> subscribeToTopic(String topic) async {
    final normalized = topic.trim();
    if (normalized.isEmpty) return;
    await _firebaseMessaging.subscribeToTopic(normalized);
  }

  static Future<void> unSubscribeToTopic(String topic) async {
    final normalized = topic.trim();
    if (normalized.isEmpty) return;
    await _firebaseMessaging.unsubscribeFromTopic(normalized);
  }

  static Future<ServiceAccountCredentials> _loadServiceAccount() async {
    final jsonStr = await rootBundle.loadString(
      EnvConfig.fcmServiceAccountPath,
    );
    return ServiceAccountCredentials.fromJson(jsonStr);
  }

  static Future<String> _getAccessToken() async {
    final credentials = await _loadServiceAccount();
    const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final authClient = await clientViaServiceAccount(credentials, scopes);
    return authClient.credentials.accessToken.data;
  }

  static Future<void> sendNotificationToTokens({
    required List<String> tokens,
    required Map<String, dynamic> payloadData,
  }) async {
    final accessToken = await _getAccessToken();
    final projectId = EnvConfig.fcmProjectId;
    if (projectId.isEmpty) return;

    for (final token in tokens) {
      final payload = {
        'message': {
          'token': token,
          'notification': {
            'title': payloadData['title'],
            'body': payloadData['body'],
            if (payloadData['image'] != null) 'image': payloadData['image'],
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            ...?payloadData['data'],
          },
        },
      };

      try {
        await _dio.post(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          ),
          data: jsonEncode(payload),
        );
      } catch (_) {}
    }
  }

  static Future<bool> sendNotificationToTopic({
    String? image,
    String? id,
    Map<String, dynamic>? data,
    Map<String, String>? stringData,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      final projectId = EnvConfig.fcmProjectId;
      if (projectId.isEmpty) return false;

      final topic = data?[DataKey.topicId.key]?.toString() ?? '';
      if (topic.isEmpty) return false;

      final candidateId = (id ?? data?['id'])?.toString().trim();
      final notificationId = (candidateId == null || candidateId.isEmpty)
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : candidateId;

      final payload = {
        'message': {
          'topic': topic,
          'notification': {
            'title':
                stringData?['title'] ?? stringData?['titleTopic'] ?? 'No Title',
            'body': stringData?['body'] ?? 'No Body',
            if (image != null) 'image': image,
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            ...?stringData,
          },
        },
      };

      final response = await _dio.post(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
        data: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        return false;
      }

      final local = {
        ...?data,
        'id': notificationId,
        if (data?['createdAt'] == null)
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        if (data?['updatedAt'] == null)
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
      _emitNotification(NotificationModel.fromJson(local));
      return true;
    } catch (_) {
      return false;
    }
  }

  static void _emitNotification(NotificationModel model) {
    if (_notificationsController.isClosed) return;
    _notificationsController.add(model);
  }
}
