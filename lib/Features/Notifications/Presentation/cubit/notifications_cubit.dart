import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../Core/LocalStorage/get_local_storage.dart';
import '../../../../Core/Services/Notifications/notification_model.dart';
import '../../Data/notification_source.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(const NotificationsState());

  StreamSubscription? _subscription;

  Future<void> init() async {
    emit(
      state.copyWith(
        loading: true,
        errorMessage: null,
      ),
    );

    await _subscription?.cancel();
    _subscription = null;

    _subscription =
        NotificationSource.listenNotificationsForTopics().listen((either) {
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
          log("list :${notifications.toSet()} ");
          final unread = notifications.where((item) => !item.open).length;
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
    final email = GetLocalStorage.getEmailUser().trim();
    if (state.notificationsList.isEmpty) return;

    bool hasFailure = false;
    for (final notification in state.notificationsList) {
      if (!notification.open) {
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
        if (item.open) return item;
        return item.copyWith(
          open: true,
        );
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
    final email = GetLocalStorage.getEmailUser().trim();

    final index = state.notificationsList.indexWhere(
      (notification) => notification.id == notificationId,
    );
    if (index == -1) return;

    final model = state.notificationsList[index];
    bool hasFailure = false;
    if (!model.read) {
      final result = await NotificationSource.markReadIn(model, email);
      result.fold(
        (_) => hasFailure = true,
        (_) {},
      );
    }

    final updated = state.notificationsList.map((notification) {
      if (notification.id != notificationId) return notification;
      return notification.read
          ? notification
          : notification.copyWith(
              read: true,
              open: true,
            );
    }).toList();

    emit(
      state.copyWith(
        notificationsList: updated,
        badgeCount: updated.where((item) => !item.open).length,
        errorMessage:
            hasFailure ? 'Failed to mark notification as readIn' : null,
      ),
    );
  }

  Future<void> clear({bool keepAllUsers = false}) async {
    await _subscription?.cancel();
    _subscription = null;

    emit(
      state.copyWith(
        loading: false,
        badgeCount: 0,
        notificationsList: const [],
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
