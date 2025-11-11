import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import '../../Storage/Local/local_storage_keys.dart';
import '../../Storage/Local/local_storage_service.dart';
class NotificationServices {
 static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
 static final Dio _dio = Dio();

 static Future<void> initFCM() async {
    await _firebaseMessaging.requestPermission();
    final tokenFCM = await _firebaseMessaging.getToken();
    debugPrint("✅ tokenFCM:: $tokenFCM");
    
    final tokenIn = await LocalStorageService.getValue(
      LocalStorageKeys.tokenFCM,
      defaultValue: null,
    );
    
    if (tokenIn == null || tokenIn == '' && tokenFCM != tokenIn) {
      await LocalStorageService.setValue(LocalStorageKeys.tokenFCM, tokenFCM);
    }
    
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      debugPrint(
        "📲 onMessageOpenedAppData:: ${message.notification?.toMap()}",
      );
    });
    
    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint("📥 onMessage:: ${message.notification?.toMap()}");
      // final notification = message.notification;
      // if (notification != null) {
      //   final title = notification.title ?? 'No Title';
      //   final body = notification.body ?? 'No Body';
      // await  LocalNotificationService.showNotification(title: title, body: body);
      // }
    });
  }


 static Future<void>  subscribeToTopic(String topic) async =>
      await _firebaseMessaging.subscribeToTopic(topic);
      
 static Future<void> unSubscribeToTopic(String topic) async =>
      await _firebaseMessaging.unsubscribeFromTopic(topic);

 static Future<ServiceAccountCredentials> _loadServiceAccount() async {
    final jsonStr = await rootBundle.loadString('assets/service_account.json');
    return ServiceAccountCredentials.fromJson(jsonStr);
  }

 static Future<String> _getAccessToken() async {
    final credentials = await _loadServiceAccount();
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final authClient = await clientViaServiceAccount(credentials, scopes);
    return authClient.credentials.accessToken.data;
  }

  /// Send notification to specific tokens
 static Future<void> sendNotificationToTokens({
    required List<String> tokens,
    required Map<String, dynamic> payloadData,
  }) async {
    final accessToken = await _getAccessToken();
    const projectId = 'areameasurement-21340';
    
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
          debugPrint('✅ Notification sent to token');
        } else {
          debugPrint(
            '❌ Error sending notification: ${response.statusCode} - ${response.data}',
          );
        }
      } catch (e) {
        debugPrint('❌ Dio error: $e');
      }
    }
  }

  /// Send notification to a topic
 static Future<bool> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    String? image,
    Map<String, String>? data,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      const projectId = 'areameasurement-21340';
      
      final payload = {
        "message": {
          "topic": topic,
          "notification": {
            "title": title,
            "body": body,
            if (image != null) "image": image,
          },
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "status": "done",
            ...data ?? {},
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
        debugPrint('✅ Notification sent to topic: $topic');
        return true;
      } else {
        debugPrint(
          '❌ Error sending to topic: ${response.statusCode} - ${response.data}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending notification to topic: $e');
      return false;
    }
  }

  /// Send notification to multiple topics
  Future<void> sendNotificationToMultipleTopics({
    required List<String> topics,
    required String title,
    required String body,
    String? image,
    Map<String, String>? data,
  }) async {
    for (final topic in topics) {
      await sendNotificationToTopic(
        topic: topic,
        title: title,
        body: body,
        image: image,
        data: data,
      );
    }
  }
}

