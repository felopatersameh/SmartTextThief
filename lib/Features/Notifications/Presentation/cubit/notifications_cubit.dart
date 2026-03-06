import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../Core/Services/Notifications/notification_model.dart';
import '../../Data/notification_source.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(const NotificationsState());

  StreamSubscription? _subscription;
  bool _initialized = false;

  Future<void> init({bool fetchOnInit = true}) async {
    if (_initialized) {
      if (fetchOnInit) {
        await refresh();
      }
      return;
    }

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
          final merged = _mergeNotifications(
            existing: state.notificationsList,
            incoming: notifications,
          );
          final unread = merged.where((item) => !item.read).length;
          emit(
            state.copyWith(
              loading: false,
              notificationsList: merged,
              badgeCount: unread,
              errorMessage: null,
            ),
          );
        },
      );
    });

    _initialized = true;
    if (fetchOnInit) {
      await refresh(showLoading: true);
    } else {
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> ensureInitialized() async {
    await init(fetchOnInit: false);
  }

  Future<void> refresh({bool showLoading = false}) async {
    if (!_initialized) {
      await init(fetchOnInit: true);
      return;
    }

    if (showLoading) {
      emit(state.copyWith(loading: true, errorMessage: null));
    }

    final response = await NotificationSource.fetchFromApi();
    response.fold(
      (failure) {
        emit(
          state.copyWith(
            loading: false,
            errorMessage: failure.message,
          ),
        );
      },
      (incoming) {
        final merged = _mergeNotifications(
          existing: state.notificationsList,
          incoming: incoming,
        );
        emit(
          state.copyWith(
            loading: false,
            notificationsList: merged,
            badgeCount: merged.where((item) => !item.read).length,
            errorMessage: null,
          ),
        );
      },
    );
  }

  /// Mark all notifications as read when opening the notifications page.
  Future<void> markAllAsRead() async {
    if (state.notificationsList.isEmpty) return;

    final unread = state.notificationsList.where((n) => !n.read).toList();
    if (unread.isEmpty) return;

    final ids = unread.map((n) => n.id).toList(growable: false);
    bool hasFailure = false;

    final result = await NotificationSource.markReadByIds(ids);
    result.fold(
      (_) => hasFailure = true,
      (_) {},
    );

    final updated = state.notificationsList
        .map(
          (n) => n.read ? n : n.copyWith(read: true),
        )
        .toList(growable: false);

    emit(
      state.copyWith(
        notificationsList: updated,
        badgeCount: 0,
        errorMessage:
            hasFailure ? 'Failed to mark some notifications as read' : null,
      ),
    );
  }

  /// Mark a single notification as read (used e.g. when opened from outside app).
  Future<void> markNotificationRead(String notificationId) async {
    final normalizedId = notificationId.trim();
    if (normalizedId.isEmpty) return;

    bool hasFailure = false;
    final result = await NotificationSource.markReadByIds(<String>[
      normalizedId,
    ]);
    result.fold(
      (_) => hasFailure = true,
      (_) {},
    );

    final updated = state.notificationsList.map((notification) { 
      if (notification.id != normalizedId) return notification;
      return notification.read
          ? notification
          : notification.copyWith(
              read: true,
            );
    }).toList(growable: false);

    emit(
      state.copyWith(
        notificationsList: updated,
        badgeCount: updated.where((item) => !item.read).length,
        errorMessage:
            hasFailure ? 'Failed to mark notification as read' : null,
      ),
    );
  }

  Future<void> openNotification(String notificationId) async {
    final normalizedId = notificationId.trim();
    if (normalizedId.isEmpty) return;

    bool hasFailure = false;
    final result = await NotificationSource.markOpenedByIds(<String>[
      normalizedId,
    ]);
    result.fold(
      (_) => hasFailure = true,
      (_) {},
    );

    final updated = state.notificationsList.map((notification) {
      if (notification.id != normalizedId) return notification;
      return notification.open ? notification : notification.copyWith(open: true);
    }).toList(growable: false);

    emit(
      state.copyWith(
        notificationsList: updated,
        badgeCount: updated.where((item) => !item.read).length,
        errorMessage: hasFailure ? 'Failed to mark notification as open' : null,
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
    _initialized = false;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    return super.close();
  }

  List<NotificationModel> _mergeNotifications({
    required List<NotificationModel> existing,
    required List<NotificationModel> incoming,
  }) {
    final map = <String, NotificationModel>{
      for (final item in existing) item.id: item,
    };

    bool shouldReplace(NotificationModel oldModel, NotificationModel newModel) {
      final oldDate = oldModel.updatedAt ??
          oldModel.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final newDate = newModel.updatedAt ??
          newModel.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return newDate.isAfter(oldDate);
    }

    for (final item in incoming) {
      final old = map[item.id];
      if (old == null || shouldReplace(old, item)) {
        map[item.id] = item;
      }
    }

    final merged = map.values.toList(growable: false)
      ..sort((a, b) {
        final aDate =
            a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    return merged;
  }
}
