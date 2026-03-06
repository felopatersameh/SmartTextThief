import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../Core/Services/Api/api_endpoints.dart';
import '../../../Core/Services/Api/api_service.dart';
import '../../../Core/Services/Error/failure_model.dart';
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
      if (controller.isClosed) return;
      final sorted = notificationsById.values.toList()
        ..sort((a, b) {
          final aDate = a.updatedAt ??
              a.createdAt ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.updatedAt ??
              b.createdAt ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });

      controller.add(Right(sorted));
    }

    bool shouldReplace(
      NotificationModel oldModel,
      NotificationModel newModel,
    ) {
      final oldDate = oldModel.updatedAt ??
          oldModel.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final newDate = newModel.updatedAt ??
          newModel.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return newDate.isAfter(oldDate);
    }

    controller.onListen = () async {
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

  static Future<Either<FailureModel, List<NotificationModel>>>
      fetchFromApi() async {
    try {
      final response =
          await DioHelper.getData(path: ApiEndpoints.notifications);
      if (!response.status) {
        return Left(
          FailureModel(
            error: 'api_error',
            message: response.message.isEmpty
                ? 'Failed to load notifications'
                : response.message,
          ),
        );
      }

      final data = response.data;
      if (data is! List) return const Right(<NotificationModel>[]);

      final parsed = <NotificationModel>[];
      for (final item in data) {
        if (item is! Map) continue;
        parsed.add(NotificationModel.fromJson(Map<String, dynamic>.from(item)));
      }
      return Right(parsed);
    } on DioException catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: error.message ?? 'Failed to load notifications',
        ),
      );
    } catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: 'Failed to load notifications',
        ),
      );
    }
  }

  static Future<Either<FailureModel, bool>> markOpenedByIds(
    List<String> ids,
  ) {
    return _markNotifications(
      path: ApiEndpoints.notificationsOpen,
      ids: ids,
    );
  }

  static Future<Either<FailureModel, bool>> markReadByIds(
    List<String> ids,
  ) {
    return _markNotifications(
      path: ApiEndpoints.notificationsRead,
      ids: ids,
    );
  }

  static Future<Either<FailureModel, bool>> _markNotifications({
    required String path,
    required List<String> ids,
  }) async {
    final uniqueIds = ids
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (uniqueIds.isEmpty) return const Right(true);

    try {
      final response = await DioHelper.putData(
        path: path,
        data: {
          'notificationIds': uniqueIds,
        },
      );

      if (response.status) return const Right(true);
      return Left(
        FailureModel(
          error: 'api_error',
          message:
              response.message.isEmpty ? 'Operation failed' : response.message,
        ),
      );
    } on DioException catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: error.message ?? 'Operation failed',
        ),
      );
    } catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: 'Operation failed',
        ),
      );
    }
  }
}
