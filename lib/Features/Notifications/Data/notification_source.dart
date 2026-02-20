import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../Core/Services/Firebase/failure_model.dart';
import '../../../Core/Services/Notifications/notification_model.dart';
import '../../../Core/Services/Notifications/notification_services.dart';

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
    final notificationsById = <String, NotificationModel>{};
    StreamSubscription<NotificationModel>? subscription;

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
      emitNotifications();
      subscription = NotificationServices.notificationsStream.listen(
        (notification) {
          if (!normalizedTopics.contains(notification.topicId)) {
            return;
          }
          notificationsById[notification.id] = notification;
          emitNotifications();
        },
        onError: (error) {
          if (!controller.isClosed) {
            controller.add(
              Left(
                FailureModel(
                  error: error.toString(),
                  message: 'Notification stream error',
                ),
              ),
            );
          }
        },
      );
    };

    controller.onCancel = () async {
      await subscription?.cancel();
      notificationsById.clear();
    };

    return controller.stream;
  }

  static Future<Either<FailureModel, bool>> markReadOut(
    NotificationModel model,
    String email,
  ) async {
    return const Right(true);
  }

  static Future<Either<FailureModel, bool>> markReadIn(
    NotificationModel model,
    String email,
  ) async {
    return const Right(true);
  }
}
