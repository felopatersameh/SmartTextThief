import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import 'package:smart_text_thief/Core/Services/Firebase/firebase_service.dart';
import 'package:smart_text_thief/Core/Storage/Local/get_local_storage.dart';
import 'package:smart_text_thief/Core/Utils/Enums/collection_key.dart';
import '../../Storage/Local/local_storage_keys.dart';
import '../../Storage/Local/local_storage_service.dart';
import '../../Utils/Enums/data_key.dart';

class NotificationServices {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final Dio _dio = Dio();

  static Function(RemoteMessage)? onMessageOpenedAppCallback;
  static Function(RemoteMessage)? onMessageCallback;

  static Future<void> initFCM() async {
    await _firebaseMessaging.requestPermission();
    final tokenFCM = await _firebaseMessaging.getToken();
    //debugPrint("✅ tokenFCM:: $tokenFCM");

    final tokenIn = await LocalStorageService.getValue(
      LocalStorageKeys.tokenFCM,
      defaultValue: null,
    );

    if (tokenIn == null || tokenIn == '' && tokenFCM.toString() != tokenIn.toString()) {
      await LocalStorageService.setValue(LocalStorageKeys.tokenFCM, tokenFCM);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      //debugPrint("📲 onMessageOpenedApp:: ${message.notification?.toMap()}");
      //debugPrint("📲 data:: ${message.data}");
      if (onMessageOpenedAppCallback != null) {
        onMessageOpenedAppCallback!(message);
      }
    });

    FirebaseMessaging.onMessage.listen((message) async {
      //debugPrint("📥 onMessage:: ${message.notification?.toMap()}");
      //debugPrint("📥 data:: ${message.data}");

      if (onMessageCallback != null) {
        onMessageCallback!(message);
      }
    });
  }

  static Future<void> subscribeToTopic(String topic) async {
    final id = GetLocalStorage.getIdUser();
    final response = await FirebaseServices.instance.updateData(
      CollectionKey.users.key,
      id,
      {
        DataKey.subscribedTopics.key: FieldValue.arrayUnion([topic]),
      },
    );
    // log("response subscribeToTopic  ::${response.toJson()}");
    if (!response.status) return;
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  static Future<void> unSubscribeToTopic(String topic) async {
    final id = GetLocalStorage.getIdUser();
    final response = await FirebaseServices.instance.updateData(
      CollectionKey.notification.key,
      id,
      {
        DataKey.subscribedTopics.key: FieldValue.arrayRemove([topic]),
      },
    );
    if (!response.status) return;
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  static Future<ServiceAccountCredentials> _loadServiceAccount() async {
    final jsonStr = await rootBundle.loadString('assets/service_account.json');
    // log("jsonStr:: $jsonStr");
    return ServiceAccountCredentials.fromJson(jsonStr);
  }

  static Future<String> _getAccessToken() async {
    final credentials = await _loadServiceAccount();
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final authClient = await clientViaServiceAccount(credentials, scopes);
    // log("authClient:: ${authClient.credentials.accessToken.data}");
    return authClient.credentials.accessToken.data;
  }

  /// Send notification to specific tokens
  static Future<void> sendNotificationToTokens({
    required List<String> tokens,
    required Map<String, dynamic> payloadData,
  }) async {
    final accessToken = await _getAccessToken();
    const projectId = 'smarttextthief';

    for (final token in tokens) {
      final payload = {
        "message": {
          "token": token,
          "notification": {
            "title": payloadData['title'],
            "body": payloadData['body'],
            if (payloadData['image'] != null) "image": payloadData['image'],
          },
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "status": "done",
            ...payloadData['data'] ?? {},
          },
        },
      };

      try {
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

        if (response.statusCode == 200) {
          //debugPrint('✅ Notification sent to token');
        } else {
          //debugPrint(
            // '❌ Error sending notification: ${response.statusCode} - ${response.data}',
          // );
        }
      } catch (e) {
        //debugPrint('❌ Dio error: $e');
      }
    }
  }

  /// Send notification to a topic
  static Future<bool> sendNotificationToTopic({
    required String topic,
    String? image,
    Map<String, dynamic>? data,
    Map<String, String>? stringData,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      const projectId = 'smarttextthief';

      final payload = {
        "message": {
          "topic": topic,
          "notification": {
            "title": stringData?['titleTopic'] ?? "No Title",
            "body": stringData?['body'] ?? "No Body",
            if (image != null) "image": image,
          },
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "status": "done",
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

      if (response.statusCode == 200) {
        //debugPrint('✅ Notification sent to topic: $topic');
        FirebaseServices.instance.addData(
          CollectionKey.notification.key,
          data?["topicId"],
          data ?? {},
        );
        return true;
      } else {
        //debugPrint(
          // '❌ Error sending to topic: ${response.statusCode} - ${response.data}',
        // );
        return false;
      }
    } catch (e) {
      //debugPrint('❌ Error sending notification to topic: $e');
      return false;
    }
  }

  /// Send notification to multiple topics
  static Future<void> sendNotificationToMultipleTopics({
    required List<String> topics,
    String? image,
    Map<String, String>? data,
  }) async {
    for (final topic in topics) {
      await sendNotificationToTopic(topic: topic, image: image, data: data);
    }
  }
}
