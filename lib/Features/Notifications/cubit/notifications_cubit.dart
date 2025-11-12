import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_text_thief/Core/Utils/Enums/data_key.dart';
import '../../../Core/Utils/Enums/collection_key.dart';
import '../../../Core/Services/Firebase/firebase_service.dart';

import '../../../Core/Utils/Models/notification_model.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(NotificationsState());

  Future<void> init(List<String> subscribedTopics) async {
    debugPrint('NotificationsCubit.init called with topics: $subscribedTopics');
    emit(state.copyWith(loading: true, subscribedTopics: subscribedTopics));
    debugPrint('Emitted loading=true and added subscribedTopics');

    final List<NotificationModel> notificationsList = [];
    int newBadgeCount = 0;
    debugPrint(
      'Initialized notificationsList with ${notificationsList.length} notifications, badgeCount: $newBadgeCount',
    );

    final Map<String, StreamSubscription> subscriptions = {};
    debugPrint('Initialized empty subscriptions map');
    if (subscribedTopics.isEmpty) {
      emit(state.copyWith(loading: false));
      return;
    }
    for (var topic in subscribedTopics) {
      debugPrint('Setting up stream for topic: $topic');
      final response = FirebaseServices.instance.findDocsInListStream(
        CollectionKey.notification.key,
        topic,
        nameField: DataKey.topicId.key,
      );
      debugPrint('Obtained stream for topic: $topic');

      final subscription = response.listen(
        (response) {
          log("message response::${response.toJson()}");
          if (response.status) {
            debugPrint('Received stream response for topic: $topic');
            for (final element in response.data) {
              final data = NotificationModel.fromJson(element);
              debugPrint('Parsed NotificationModel: ${data.toJson()}');

              if (!notificationsList.any((n) => n.topicId == data.topicId)) {
                notificationsList.add(data);
                debugPrint(
                  'Added new notification with topicId: ${data.topicId}',
                );
                if (!data.readOut) {
                  newBadgeCount++;
                  debugPrint('Incremented badgeCount, now: $newBadgeCount');
                }
              }
            }

            debugPrint(
              'Emitting updated notificationsList (${notificationsList.length}) and badgeCount ($newBadgeCount)',
            );
          }
          emit(
            state.copyWith(
              notificationsList: notificationsList,
              badgeCount: newBadgeCount,
            ),
          );
        },
        onError: (error) {
          debugPrint('Stream error for topic $topic: $error');
        },
      );
      subscriptions[topic] = subscription;
      debugPrint('Added stream subscription for topic: $topic');
    }

    debugPrint('Finished setup for all topic streams');
    emit(state.copyWith(loading: false));
  }

  void disposeSubscriptions() {
    for (final subscription in state.streamSubscriptions.values) {
      subscription.cancel();
    }
  }

  Future<void> readout() async {
    // final id = GetLocalStorage.getIdUser();
    // final updatedList = state.notificationsList.map((e) {
    //   if (!e.readOut) {
    //     return e.copyWith(readOut: true);
    //   }
    //   return e;
    // }).toList();
    // final response = await FirebaseServices.instance.addOrUpdateNotifications(
    //   id,
    //   updatedList.map((e) => e.toJson()).toList(),
    //   DataKey.subscribedTopics.key,
    // );

    // log("resonse update:: ${response.toJson()}");
    // emit(state.copyWith(badgeCount: 0, notificationsList: updatedList));
  }

  Future<void> readIn(String notificationId) async {
    // final userId = GetLocalStorage.getIdUser();
    // final List<NotificationModel> currentList = List.from(
    //   state.notificationsList,
    // );

    // final index = currentList.indexWhere((e) => e.topicId == notificationId);

    // if (index != -1 && !currentList[index].readIn) {
    //   final updatedNotification = currentList[index].copyWith(readIn: true);
    //   currentList[index] = updatedNotification;

    //   await FirebaseServices.instance.addOrUpdateNotification(
    //     userId,
    //     updatedNotification.toJson(),
    //     DataKey.subscribedTopics.key,
    //   );
    //   emit(state.copyWith(notificationsList: currentList));
    // }
  }

  Future<void> readALl(String notificationId) async {
    // final userId = GetLocalStorage.getIdUser();
    // int newBadgeCount = state.badgeCount;
    // final updatedList = state.notificationsList.map((e) {
    //   if (e.topicId == notificationId && !e.readIn) {
    //     newBadgeCount = newBadgeCount > 0 ? newBadgeCount - 1 : 0;
    //     return e.copyWith(readIn: true, readOut: true);
    //   }
    //   return e;
    // }).toList();

    // await FirebaseServices.instance.addOrUpdateNotifications(
    //   userId,
    //   updatedList.map((e) => e.toJson()).toList(),
    //   DataKey.subscribedTopics.key,
    // );
    // emit(
    //   state.copyWith(badgeCount: newBadgeCount, notificationsList: updatedList),
    // );
  }

  Future<void> addedLocal(NotificationModel model) async {
    final newBadgeCount = state.badgeCount + 1;
    emit(
      state.copyWith(
        notificationsList: [model, ...state.notificationsList],
        badgeCount: newBadgeCount,
      ),
    );
  }

  Future<void> clear() async {
     disposeSubscriptions();
    emit(NotificationsState());
  }

  @override
  Future<void> close() {
    disposeSubscriptions();
    return super.close();
  }
}
