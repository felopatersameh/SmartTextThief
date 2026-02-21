import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../Core/LocalStorage/get_local_storage.dart';
import '../../../../Core/Resources/resources.dart';
import '../../../../Core/Services/Notifications/notification_model.dart';
import '../../../../Core/Services/Notifications/notification_services.dart';
import '../../Data/notification_source.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(const NotificationsState());

  StreamSubscription? _subscription;

  Future<void> init(List<String> subscribedTopics) async {
    final normalizedTopics = subscribedTopics
        .map((topic) => topic.trim())
        .where((topic) => topic.isNotEmpty)
        .toSet()
        .toList();

    emit(
      state.copyWith(
        loading: true,
        subscribedTopics: normalizedTopics,
        errorMessage: null,
      ),
    );

    await _subscription?.cancel();
    _subscription = null;

    if (normalizedTopics.isEmpty) {
      emit(
        state.copyWith(
          loading: false,
          notificationsList: const [],
          badgeCount: 0,
        ),
      );
      return;
    }

    _subscription = NotificationSource.listenNotificationsForTopics(
      normalizedTopics,
    ).listen((either) {
      either.fold(
        (failure) {
          emit(
            state.copyWith(
              loading: false,
              errorMessage: failure.message,
            ),
          );
        },
        (notifications) {
          final unread = notifications.where((item) => !item.readOut).length;
          emit(
            state.copyWith(
              loading: false,
              notificationsList: notifications,
              badgeCount: unread,
              errorMessage: null,
            ),
          );
        },
      );
    });
  }

  Future<void> readout() async {
    final email = GetLocalStorage.getEmailUser();
    if (email.isEmpty) return;
    if (state.notificationsList.isEmpty) return;

    bool hasFailure = false;
    for (final notification in state.notificationsList) {
      if (!notification.readOut) {
        final result =
            await NotificationSource.markReadOut(notification, email);
        result.fold(
          (_) => hasFailure = true,
          (_) {},
        );
      }
    }

    final updated = state.notificationsList.map(
      (item) {
        if (item.readOut) return item;
        final readOut = <String>{email, ...item.listReadOut}.toList();
        return item.copyWith(readOut: readOut);
      },
    ).toList();

    emit(
      state.copyWith(
        notificationsList: updated,
        badgeCount: 0,
        errorMessage: hasFailure ? 'Failed to mark some notifications' : null,
      ),
    );
  }

  Future<void> readIn(String notificationId) async {
    final email = GetLocalStorage.getEmailUser();
    if (email.isEmpty) return;

    final index = state.notificationsList.indexWhere(
      (notification) => notification.id == notificationId,
    );
    if (index == -1) return;

    final model = state.notificationsList[index];
    bool hasFailure = false;
    if (!model.readIn) {
      final result = await NotificationSource.markReadIn(model, email);
      result.fold(
        (_) => hasFailure = true,
        (_) {},
      );
    }

    final updated = state.notificationsList.map((notification) {
      if (notification.id != notificationId) return notification;
      return notification.readIn
          ? notification
          : notification.copyWith(
              readIn: <String>{email, ...notification.listReadIn}.toList(),
            );
    }).toList();

    emit(
      state.copyWith(
        notificationsList: updated,
        errorMessage: hasFailure ? 'Failed to mark notification as readIn' : null,
      ),
    );
  }

  Future<void> clear({bool keepAllUsers = false}) async {
    await _subscription?.cancel();
    _subscription = null;

    for (final topic in state.subscribedTopics) {
      if (keepAllUsers && topic == AppConstants.allUsersTopic) continue;
      await NotificationServices.unSubscribeToTopic(topic);
    }

    emit(
      state.copyWith(
        loading: false,
        badgeCount: 0,
        notificationsList: const [],
        subscribedTopics:
            keepAllUsers ? [AppConstants.allUsersTopic] : const [],
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    return super.close();
  }
}
