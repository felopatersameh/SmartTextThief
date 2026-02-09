import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../Core/Services/Firebase/failure_model.dart';
import '../../../Core/Services/Firebase/firebase_service.dart';
import '../../../Core/Services/Notifications/notification_model.dart';
import '../../../Core/Utils/Enums/collection_key.dart';
import '../../../Core/Utils/Enums/data_key.dart';

class NotificationSource {
  static Stream<Either<FailureModel, List<NotificationModel>>>
      listenNotificationsForTopics(List<String> topics) {
    final normalizedTopics = topics
        .map((topic) => topic.trim())
        .where((topic) => topic.isNotEmpty)
        .toSet()
        .toList();

    if (normalizedTopics.isEmpty) {
      return Stream.value(const Right(<NotificationModel>[]));
    }

    final controller =
        StreamController<Either<FailureModel, List<NotificationModel>>>();
    final subscriptions = <StreamSubscription>[];
    final notificationsById = <String, NotificationModel>{};
    final idsByTopic = <String, Set<String>>{};

    void emitNotifications() {
      final sorted = notificationsById.values.toList()
        ..sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });

      if (!controller.isClosed) {
        controller.add(Right(sorted));
      }
    }

    controller.onListen = () {
      try {
        for (final topic in normalizedTopics) {
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
                        error: 'Firestore Error',
                        message: response.message,
                      ),
                    ),
                  );
                }
                return;
              }

              final parsed = _parseNotificationMaps(response.data)
                  .map(NotificationModel.fromJson)
                  .toList();

              final previousIds = idsByTopic[topic] ?? <String>{};
              for (final oldId in previousIds) {
                notificationsById.remove(oldId);
              }

              final currentIds = <String>{};
              for (final notification in parsed) {
                currentIds.add(notification.id);
                notificationsById[notification.id] = notification;
              }
              idsByTopic[topic] = currentIds;

              emitNotifications();
            },
            onError: (error) {
              if (!controller.isClosed) {
                controller.add(
                  Left(
                    FailureModel(
                      error: error.toString(),
                      message: 'Stream Listening Error',
                    ),
                  ),
                );
              }
            },
          );

          subscriptions.add(subscription);
        }
      } catch (error) {
        if (!controller.isClosed) {
          controller.add(
            Left(
              FailureModel(
                error: error.toString(),
                message: 'Unexpected Stream Error',
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
      idsByTopic.clear();
      notificationsById.clear();
    };

    return controller.stream;
  }

  static Future<Either<FailureModel, bool>> markReadOut(
    NotificationModel model,
    String email,
  ) async {
    try {
      final response = await FirebaseServices.instance.updateData(
        CollectionKey.notification.key,
        model.id,
        {
          DataKey.readOut.key: FieldValue.arrayUnion([email]),
        },
      );

      if (!response.status) {
        return Left(
          FailureModel(
            error: response.failure?.error,
            message: response.message,
          ),
        );
      }

      return const Right(true);
    } catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: 'Failed to mark notification as readOut',
        ),
      );
    }
  }

  static Future<Either<FailureModel, bool>> markReadIn(
    NotificationModel model,
    String email,
  ) async {
    try {
      final response = await FirebaseServices.instance.updateData(
        CollectionKey.notification.key,
        model.id,
        {
          DataKey.readIn.key: FieldValue.arrayUnion([email]),
        },
      );

      if (!response.status) {
        return Left(
          FailureModel(
            error: response.failure?.error,
            message: response.message,
          ),
        );
      }

      return const Right(true);
    } catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: 'Failed to mark notification as readIn',
        ),
      );
    }
  }

  static List<Map<String, dynamic>> _parseNotificationMaps(dynamic rawData) {
    if (rawData is! List) return const <Map<String, dynamic>>[];

    final result = <Map<String, dynamic>>[];
    for (final item in rawData) {
      if (item is Map<String, dynamic>) {
        result.add(item);
      } else if (item is Map) {
        result.add(Map<String, dynamic>.from(item));
      }
    }
    return result;
  }
}
