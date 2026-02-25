import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../Core/Services/Api/api_endpoints.dart';
import '../../../Core/Services/Api/api_service.dart';
import '../../../Core/Services/Firebase/failure_model.dart';
import '../../../Core/Services/Notifications/notification_model.dart';
import '../../../Core/Services/Notifications/notification_services.dart';

class NotificationSource {
static Stream<Either<FailureModel, List<NotificationModel>>>
    listenNotificationsForTopics() {
  final controller =
      StreamController<Either<FailureModel, List<NotificationModel>>>();

  final notificationsById = <String, NotificationModel>{};
  StreamSubscription<NotificationModel>? subscription;

  void emitNotifications() {
    if (controller.isClosed || notificationsById.isEmpty) return;

    final sorted = notificationsById.values.toList()
      ..sort((a, b) {
        final aDate =
            a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    controller.add(Right(sorted.take(20).toList()));
  }

  bool shouldReplace(
    NotificationModel oldModel,
    NotificationModel newModel,
  ) {
    final oldDate =
        oldModel.updatedAt ?? oldModel.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

    final newDate =
        newModel.updatedAt ?? newModel.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

    return newDate.isAfter(oldDate);
  }

  Future<void> loadFromApi() async {
    try {
      final response =
          await DioHelper.getData(path: ApiEndpoints.notifications);

      if (!response.status) {
        if (!controller.isClosed) {
          controller.add(
            Left(
              FailureModel(
                error: 'api_error',
                message: response.message.isEmpty
                    ? 'Failed to load notifications'
                    : response.message,
              ),
            ),
          );
        }
        return;
      }

      final data = response.data;

      if (data is List) {
        for (final item in data) {
          if (item is! Map) continue;

          final model = NotificationModel.fromJson(
            Map<String, dynamic>.from(item),
          );

          final existing = notificationsById[model.id];

          if (existing == null || shouldReplace(existing, model)) {
            notificationsById[model.id] = model;
          }
        }

        emitNotifications();
      }
    } on DioException catch (error) {
      if (!controller.isClosed) {
        controller.add(
          Left(
            FailureModel(
              error: error.toString(),
              message: error.message ?? 'Failed to load notifications',
            ),
          ),
        );
      }
    } catch (error) {
      if (!controller.isClosed) {
        controller.add(
          Left(
            FailureModel(
              error: error.toString(),
              message: 'Failed to load notifications',
            ),
          ),
        );
      }
    }
  }

  controller.onListen = () async {
    // ✅ 1️⃣ حمل البيانات الأول
    await loadFromApi();

    // ✅ 2️⃣ بعدها اسمع realtime
    subscription = NotificationServices.notificationsStream.listen(
      (notification) {
        final existing = notificationsById[notification.id];

        if (existing == null || shouldReplace(existing, notification)) {
          notificationsById[notification.id] = notification;
          emitNotifications();
        }
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
