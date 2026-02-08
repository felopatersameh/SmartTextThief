import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../Core/LocalStorage/get_local_storage.dart';
import '../../../../Core/Services/Notifications/notification_services.dart';

import '../../../../Core/Services/Notifications/notification_model.dart';
import '../../Data/notification_source.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(NotificationsState());

  StreamSubscription? _subscription;

  Future<void> init(List<String> subscribedTopics) async {
    emit(state.copyWith(loading: true, subscribedTopics: subscribedTopics));

    if (subscribedTopics.isEmpty) {
      emit(state.copyWith(loading: false));
      return;
    }

    // Cancel old stream if exists
    await _subscription?.cancel();

    // Start new stream
    _subscription = NotificationSource.listenNotificationsForTopics(
      subscribedTopics,
    ).listen((either) {
      either.fold(
        // Error
        (failure) {
          emit(
            state.copyWith(loading: false, errorMessage: failure.message),
          );
        },
        // Success
        (list) {
          int unread = 0;
          for (var n in list) {
            if (!n.readOut) unread++;
          }

          emit(
            state.copyWith(
              loading: false,
              notificationsList: list,
              badgeCount: unread,
            ),
          );
        },
      );
    });
  }

  Future<void> readout() async {
    final email = GetLocalStorage.getEmailUser();

    for (final n in state.notificationsList) {
      if (!n.readOut) {
        await NotificationSource.markReadOut(n, email);
      }
    }

    // Update UI
    final updated = state.notificationsList
        .map(
          (n) => n.readOut ? n : n.copyWith(readOut: [email, ...n.listReadOut]),
        )
        .toList();

    emit(state.copyWith(notificationsList: updated, badgeCount: 0));
  }

  Future<void> readIn(String notificationId) async {
    final email = GetLocalStorage.getEmailUser();

    final model = state.notificationsList.firstWhere(
      (n) => n.id == notificationId,
      // orElse: () => null,
    );

    if (!model.readIn) {
      await NotificationSource.markReadIn(model, email);
    }

    final updated = state.notificationsList.map((n) {
      if (n.id != notificationId) return n;

      return n.readIn ? n : n.copyWith(readIn: [email, ...n.listReadIn]);
    }).toList();

    emit(state.copyWith(notificationsList: updated));
  }

  Future<void> clear({bool keepAllUsers = false}) async {
    await _subscription?.cancel();

    for (var topic in state.subscribedTopics) {
      if (keepAllUsers && topic == 'allUsers') continue;
      await NotificationServices.unSubscribeToTopic(topic);
    }

    emit(
      state.copyWith(
        badgeCount: 0,
        notificationsList: [],
        subscribedTopics: keepAllUsers ? ['allUsers'] : [],
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    emit(NotificationsState());
    return super.close();
  }
}
