part of 'notifications_cubit.dart';

class NotificationsState extends Equatable {
  final bool loading;
  final List<NotificationModel> notificationsList;
  final int badgeCount;

  const NotificationsState({
    this.loading = false,
    this.notificationsList = const [],
    this.badgeCount = 0,
  });

  NotificationsState copyWith({
    bool? loading,
    List<NotificationModel>? notificationsList,
    int? badgeCount,
  }) {
    return NotificationsState(
      loading: loading ?? this.loading,
      notificationsList: notificationsList ?? this.notificationsList,
      badgeCount: badgeCount ?? this.badgeCount,
    );
  }

  @override
  List<Object> get props => [loading, notificationsList, badgeCount];
}
