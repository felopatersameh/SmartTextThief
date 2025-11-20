import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../Core/Services/Firebase/failure_model.dart';
import '../../../Core/Services/Firebase/firebase_service.dart';
import '../../../Core/Utils/Enums/collection_key.dart';
import '../../../Core/Utils/Enums/data_key.dart';
import '../../../Core/Services/Notifications/notification_model.dart';

class NotificationSource {
  /// 🔥 Stream — Listen to notifications by topics
  static Stream<Either<FailureModel, List<NotificationModel>>>
      listenNotificationsForTopics(List<String> topics) {
    if (topics.isEmpty) {
      return Stream.value(
        Right(<NotificationModel>[]),
      );
    }

    final controller =
        StreamController<Either<FailureModel, List<NotificationModel>>>();

    final List<NotificationModel> buffer = [];

    try {
      for (final topic in topics) {
        FirebaseServices.instance
            .findDocsInListStream(
              CollectionKey.notification.key,
              topic,
              nameField: DataKey.topicId.key,
            )
            .listen((response) {
          if (response.status) {
            for (final element in response.data) {
              final model = NotificationModel.fromJson(element);
              if (!buffer.any((e) => e.id == model.id)) {
                buffer.add(model);
              }
           
            }
                  buffer.sort((a, b) {
                    final DateTime aDate = a.createdAt!;
                    final DateTime bDate = b.createdAt!;
                    return bDate.compareTo(aDate);
                  });
                  controller.add(Right(buffer));
                } else {
            controller.add(
              Left(FailureModel(
                error: "Firestore Error",
                message: response.message,
              )),
            );
          }
        }, onError: (error) {
          controller.add(
            Left(FailureModel(
              error: error.toString(),
              message: "Stream Listening Error",
            )),
          );
        });
      }
    } catch (e) {
      controller.add(
        Left(FailureModel(
          error: e.toString(),
          message: "Unexpected Stream Error",
        )),
      );
    }

    return controller.stream;
  }

  /// 🔥 Mark Read Out
  static Future<Either<FailureModel, bool>> markReadOut(
      NotificationModel model, String email) async {
    try {
      await FirebaseServices.instance.updateData(
        CollectionKey.notification.key,
        model.id,
        {
          DataKey.readOut.key: FieldValue.arrayUnion([email]),
        },
      );
      return const Right(true);
    } catch (e) {
      return Left(
        FailureModel(
          error: e.toString(),
          message: "Failed to mark notification as readOut",
        ),
      );
    }
  }

  /// 🔥 Mark Read In
  static Future<Either<FailureModel, bool>> markReadIn(
      NotificationModel model, String email) async {
    try {
      await FirebaseServices.instance.updateData(
        CollectionKey.notification.key,
        model.id,
        {
          DataKey.readIn.key: FieldValue.arrayUnion([email]),
        },
      );
      return const Right(true);
    } catch (e) {
      return Left(
        FailureModel(
          error: e.toString(),
          message: "Failed to mark notification as readIn",
        ),
      );
    }
  }
}
