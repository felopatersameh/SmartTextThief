import 'package:firebase_database/firebase_database.dart';

import 'RealTimeLogic/real_time_firebase_logic.dart';

class RealtimeFirebase {
  RealtimeFirebase._();

  static final RealtimeFirebaseLogic _logic = RealtimeFirebaseLogic();

  static Future<void> initialize({String? databaseURL}) {
    return _logic.initialize(databaseURL: databaseURL);
  }

  static bool get isInitialized => _logic.isInitialized;

  static Future<String> create(
    String path,
    Map<String, dynamic> data, {
    String? id,
    Map<String, dynamic>? otherData,
  }) {
    return _logic.create(
      path,
      data,
      id: id,
      otherData: otherData,
    );
  }

  static Future<void> setData(String path, Map<String, dynamic> data) {
    return _logic.setData(path, data);
  }

  static Future<dynamic> getData(String path) {
    return _logic.getData(path);
  }

  static Future<void> updateData(
    String path,
    Map<String, dynamic> updates, {
    Map<String, dynamic>? otherUpdates,
  }) {
    return _logic.updateData(
      path,
      updates,
      otherUpdates: otherUpdates,
    );
  }

  static Future<void> deleteData(String path) {
    return _logic.deleteData(path);
  }

  static String listen(
    String path,
    Function(dynamic data, String? key) onData, {
    Function(Object error)? onError,
    String? listenerId,
  }) {
    return _logic.listen(
      path,
      onData,
      onError: onError,
      listenerId: listenerId,
    );
  }

  static Future<void> unListen(String listenerId) {
    return _logic.unListen(listenerId);
  }

  static Future<void> unlistenAll() {
    return _logic.unlistenAll();
  }

  static Future<dynamic> query(
    String path, {
    String? orderByChild,
    bool orderByKey = false,
    bool orderByValue = false,
    dynamic startAt,
    dynamic endAt,
    dynamic equalTo,
    int? limitToFirst,
    int? limitToLast,
  }) {
    return _logic.query(
      path,
      orderByChild: orderByChild,
      orderByKey: orderByKey,
      orderByValue: orderByValue,
      startAt: startAt,
      endAt: endAt,
      equalTo: equalTo,
      limitToFirst: limitToFirst,
      limitToLast: limitToLast,
    );
  }

  static String queryListen(
    String path,
    Function(dynamic data, String? key) onData, {
    String? orderByChild,
    bool orderByKey = false,
    bool orderByValue = false,
    dynamic startAt,
    dynamic endAt,
    dynamic equalTo,
    int? limitToFirst,
    int? limitToLast,
    Function(Object error)? onError,
    String? listenerId,
  }) {
    return _logic.queryListen(
      path,
      onData,
      orderByChild: orderByChild,
      orderByKey: orderByKey,
      orderByValue: orderByValue,
      startAt: startAt,
      endAt: endAt,
      equalTo: equalTo,
      limitToFirst: limitToFirst,
      limitToLast: limitToLast,
      onError: onError,
      listenerId: listenerId,
    );
  }

  static Future<void> batchUpdate(Map<String, dynamic> updates) {
    return _logic.batchUpdate(updates);
  }

  static Future<bool> exists(String path) {
    return _logic.exists(path);
  }

  static Map<String, String> get serverTimestamp => {'.sv': 'timestamp'};

  static String onConnectionState(
    Function(bool isConnected) callback, {
    String? listenerId,
  }) {
    return _logic.onConnectionState(
      callback,
      listenerId: listenerId,
    );
  }

  static int get activeListenersCount => _logic.activeListenersCount;

  static List<String> get activeListenerIds => _logic.activeListenerIds;

  static void enablePersistence() {
    _logic.enablePersistence();
  }

  static void disablePersistence() {
    _logic.disablePersistence();
  }

  static DatabaseReference ref(String path) {
    return _logic.ref(path);
  }

  static Future<void> dispose() {
    return _logic.dispose();
  }

  static Future<T?> runTransaction<T>(
    String path,
    T? Function(T? currentValue) updateFunction,
  ) {
    return _logic.runTransaction(path, updateFunction);
  }

  static Future<List<String>> pushMultiple(
    String path,
    List<Map<String, dynamic>> items,
  ) {
    return _logic.pushMultiple(path, items);
  }
}
