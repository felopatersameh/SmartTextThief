import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Core/Utils/Enums/data_key.dart';
import '../../../Core/Storage/Local/get_local_storage.dart';
import '../../../Core/Utils/Enums/collection_key.dart';
import '../../../Core/Services/Firebase/firebase_service.dart';

import '../../../Core/Utils/Models/notification_model.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(NotificationsState());

  Future<void> init(List<String> subscribedTopics) async {
    emit(state.copyWith(loading: true, subscribedTopics: subscribedTopics));

    final List<NotificationModel> notificationsList = [];
    int newBadgeCount = 0;

    final Map<String, StreamSubscription> subscriptions = {};
    if (subscribedTopics.isEmpty) {
      emit(state.copyWith(loading: false));
      return;
    }
    for (var topic in subscribedTopics) {
      final response = FirebaseServices.instance.findDocsInListStream(
        CollectionKey.notification.key,
        topic,
        nameField: DataKey.topicId.key,
      );

      final subscription = response.listen((response) {
        if (response.status) {
          for (final element in response.data) {
            final data = NotificationModel.fromJson(element);
            if (!notificationsList.any((n) => n.topicId == data.topicId)) {
              notificationsList.add(data);
              if (!data.readOut) {
                newBadgeCount++;
              }
            }
          }
        }
        emit(
          state.copyWith(
            notificationsList: notificationsList,
            badgeCount: newBadgeCount,
          ),
        );
      }, onError: (error) {});
      subscriptions[topic] = subscription;
    }

    emit(state.copyWith(loading: false));
  }

  void disposeSubscriptions() {
    for (final subscription in state.streamSubscriptions.values) {
      subscription.cancel();
    }
  }

  Future<void> readout() async {
    final email = GetLocalStorage.getEmailUser();
    final updatedList = state.notificationsList.map((e) {
      if (!e.readOut) {
        final readout = e.listReadOut;
        return e.copyWith(readOut: [email, ...readout]);
      }
      return e;
    }).toList();
    for (var element in updatedList) {
      await FirebaseServices.instance.updateData(
        CollectionKey.notification.key,
        element.topicId,
        {DataKey.readOut.key: FieldValue.arrayUnion(element.listReadOut)},
      );
    }

    emit(state.copyWith(badgeCount: 0, notificationsList: updatedList));
  }

  Future<void> readIn(String notificationId) async {
    final email = GetLocalStorage.getEmailUser();
    NotificationModel? updatedNotification;
    final updatedList = state.notificationsList.map((e) {
      if (!e.readIn && notificationId == e.topicId) {
        final readIn = e.listReadIn;
        updatedNotification = e.copyWith(readIn: [email, ...readIn]);
        return updatedNotification!;
      }
      return e;
    }).toList();

    if (updatedNotification != null) {
      await FirebaseServices.instance.updateData(
        CollectionKey.notification.key,
        updatedNotification!.topicId,
        {
          DataKey.readIn.key: FieldValue.arrayUnion(
            updatedNotification!.listReadIn,
          ),
        },
      );
    }

    emit(state.copyWith(notificationsList: updatedList));
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
