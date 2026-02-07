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
    final subscriptions = <StreamSubscription>[];
    final notificationsById = <String, NotificationModel>{};

    void emitNotifications() {
      final sortedNotifications = notificationsById.values.toList()
        ..sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
      if (!controller.isClosed) {
        controller.add(Right(sortedNotifications));
      }
    }

    controller.onListen = () {
      try {
        for (final topic in topics) {
          final subscription = FirebaseServices.instance
              .findDocsInListStream(
            CollectionKey.notification.key,
            topic,
            nameField: DataKey.topicId.key,
          )
              .listen(
            (response) {
              if (!response.status) {
                if (!controller.isClosed) {
                  controller.add(
                    Left(
                      FailureModel(
                        error: "Firestore Error",
                        message: response.message,
                      ),
                    ),
                  );
                }
                return;
              }

              final rawData = response.data;
              if (rawData is List) {
                for (final item in rawData) {
                  if (item is Map<String, dynamic>) {
                    final model = NotificationModel.fromJson(item);
                    notificationsById[model.id] = model;
                  } else if (item is Map) {
                    final model = NotificationModel.fromJson(
                      Map<String, dynamic>.from(item),
                    );
                    notificationsById[model.id] = model;
                  }
                }
              }

              emitNotifications();
            },
            onError: (error) {
              if (!controller.isClosed) {
                controller.add(
                  Left(
                    FailureModel(
                      error: error.toString(),
                      message: "Stream Listening Error",
                    ),
                  ),
                );
              }
            },
          );
          subscriptions.add(subscription);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.add(
            Left(
              FailureModel(
                error: e.toString(),
                message: "Unexpected Stream Error",
              ),
            ),
          );
        }
      }
    };

    controller.onCancel = () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
      subscriptions.clear();
    };

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
