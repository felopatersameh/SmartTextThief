part of 'notifications_cubit.dart';

class NotificationsState extends Equatable {
  static const Object _noChange = Object();

  final bool loading;
  final List<NotificationModel> notificationsList;
  final int badgeCount;
  final List<String> subscribedTopics;
  final Map<String, StreamSubscription> streamSubscriptions;
  final String? errorMessage;

  const NotificationsState({
    this.loading = false,
    this.notificationsList = const [],
    this.badgeCount = 0,
    this.subscribedTopics = const [],
    this.streamSubscriptions = const {},
    this.errorMessage,
  });

  NotificationsState copyWith({
    bool? loading,
    List<NotificationModel>? notificationsList,
    int? badgeCount,
    List<String>? subscribedTopics,
    Map<String, StreamSubscription>? streamSubscriptions,
    Object? errorMessage = _noChange,
  }) {
    return NotificationsState(
      loading: loading ?? this.loading,
      notificationsList: notificationsList ?? this.notificationsList,
      badgeCount: badgeCount ?? this.badgeCount,
      subscribedTopics: subscribedTopics ?? this.subscribedTopics,
      streamSubscriptions: streamSubscriptions ?? this.streamSubscriptions,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        notificationsList,
        badgeCount,
        subscribedTopics,
        streamSubscriptions,
        errorMessage
      ];
}
