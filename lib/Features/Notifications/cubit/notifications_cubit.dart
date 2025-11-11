import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Core/Services/Firebase/firebase_service.dart';
import 'package:smart_text_thief/Core/Storage/Local/get_local_storage.dart';
import 'package:smart_text_thief/Core/Utils/Enums/collection_key.dart';
import 'package:smart_text_thief/Core/Utils/Enums/data_key.dart';

import '../../../Core/Utils/Models/notification_model.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(NotificationsState());

  Future<void> init(List<NotificationModel> notificationsList) async {
    emit(state.copyWith(loading: true));
    int newBadgeCount = 0;
    for (var element in notificationsList) {
      if (!element.readOut) {
        ++newBadgeCount;
      }
    }
    emit(
      state.copyWith(
        notificationsList: notificationsList,
        badgeCount: newBadgeCount,
        loading: false,
      ),
    );
  }

  Future<void> readout() async {
    final id = GetLocalStorage.getIdUser();
    final updatedList = state.notificationsList.map((e) {
      if (!e.readOut) {
        return e.copyWith(readOut: true);
      }
      return e;
    }).toList();
    await FirebaseServices.instance.updateData(CollectionKey.users.key, id, {
      DataKey.userNotifications.key: updatedList,
    });
    emit(state.copyWith(badgeCount: 0, notificationsList: updatedList));
  }

  Future<void> readIn(String notificationId) async {
    final userId = GetLocalStorage.getIdUser();
    final List<NotificationModel> currentList = List.from(
      state.notificationsList,
    );

    final index = currentList.indexWhere((e) => e.id == notificationId);

    if (index != -1 && !currentList[index].readIn) {
      final updatedNotification = currentList[index].copyWith(readIn: true);
      currentList[index] = updatedNotification;

      await FirebaseServices.instance.updateData(
        CollectionKey.users.key,
        userId,
        {
          DataKey.userNotifications.key: FieldValue.arrayUnion([
            updatedNotification,
          ]),
        },
      );
      emit(state.copyWith(notificationsList: currentList));
    }
  }

  Future<void> readALl(String notificationId) async {
    final userId = GetLocalStorage.getIdUser();
    int newBadgeCount = state.badgeCount;
    final updatedList = state.notificationsList.map((e) {
      if (e.id == notificationId && !e.readIn) {
        newBadgeCount = newBadgeCount > 0 ? newBadgeCount - 1 : 0;
        return e.copyWith(readIn: true, readOut: true);
      }
      return e;
    }).toList();

    await FirebaseServices.instance.updateData(
      CollectionKey.users.key,
      userId,
      {DataKey.userNotifications.key: updatedList},
    );
    emit(
      state.copyWith(badgeCount: newBadgeCount, notificationsList: updatedList),
    );
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
}
