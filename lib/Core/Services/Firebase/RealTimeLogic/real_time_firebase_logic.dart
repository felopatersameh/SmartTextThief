import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'real_time_firebase_error_handler.dart';

class RealtimeFirebaseLogic {
  FirebaseDatabase? _database;
  final Map<String, StreamSubscription<DatabaseEvent>> _listeners =
      <String, StreamSubscription<DatabaseEvent>>{};
  bool _initialized = false;
  bool _persistenceConfigured = false;

  bool get isInitialized => _initialized && _database != null;
  int get activeListenersCount => _listeners.length;
  List<String> get activeListenerIds => _listeners.keys.toList();

  Future<void> initialize({String? databaseURL}) async {
    if (isInitialized) return;

    _database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseURL,
    );

    await _configurePersistenceIfNeeded();
    _initialized = true;
  }

  Future<String> create(
    String path,
    Map<String, dynamic> data, {
    String? id,
    Map<String, dynamic>? otherData,
  }) async {
    _ensureInitialized();

    try {
      final rootRef = _database!.ref(path);
      final newRef = (id != null && id.isNotEmpty) ? rootRef.child(id) : rootRef.push();

      final payload = {
        ...data,
        ...?otherData,
        'id_live_exam': newRef.key,
      };

      await newRef.set(payload);
      return newRef.key!;
    } catch (error) {
      RealtimeFirebaseErrorHandler.throwOperationError('Create operation', error);
    }
  }

  Future<void> setData(String path, Map<String, dynamic> data) async {
    _ensureInitialized();

    try {
      await _database!.ref(path).set({...data});
    } catch (error) {
      RealtimeFirebaseErrorHandler.throwOperationError('Set operation', error);
    }
  }

  Future<dynamic> getData(String path) async {
    _ensureInitialized();

    try {
      final snapshot = await _database!.ref(path).get();
      return snapshot.exists ? snapshot.value : null;
    } catch (error) {
      RealtimeFirebaseErrorHandler.throwOperationError('Get operation', error);
    }
  }

  Future<void> updateData(
    String path,
    Map<String, dynamic> updates, {
    Map<String, dynamic>? otherUpdates,
  }) async {
    _ensureInitialized();

    try {
      final payload = {
        ...updates,
        ...?otherUpdates,
        'dispose_exam': 0,
      };
      await _database!.ref(path).update(payload);
    } catch (error) {
      RealtimeFirebaseErrorHandler.throwOperationError('Update operation', error);
    }
  }

  Future<void> deleteData(String path) async {
    _ensureInitialized();

    try {
      await _database!.ref(path).remove();
    } catch (error) {
      RealtimeFirebaseErrorHandler.throwOperationError('Delete operation', error);
    }
  }

  String listen(
    String path,
    void Function(dynamic data, String? key) onData, {
    void Function(Object error)? onError,
    String? listenerId,
  }) {
    _ensureInitialized();

    final id = listenerId ?? '${path}_${DateTime.now().millisecondsSinceEpoch}';

    try {
      final subscription = _database!.ref(path).onValue.listen(
        (event) {
          final data = event.snapshot.exists ? event.snapshot.value : null;
          onData(data, event.snapshot.key);
        },
        onError: (error) {
          if (onError != null) {
            onError(error);
          }
        },
      );

      _listeners[id] = subscription;
      return id;
    } catch (error) {
      RealtimeFirebaseErrorHandler.throwOperationError('Listen setup', error);
    }
  }

  Future<void> unListen(String listenerId) async {
    final subscription = _listeners.remove(listenerId);
    if (subscription != null) {
      await subscription.cancel();
    }
  }

  Future<void> unlistenAll() async {
    for (final subscription in _listeners.values) {
      await subscription.cancel();
    }
    _listeners.clear();
  }

  Future<dynamic> query(
    String path, {
    String? orderByChild,
    bool orderByKey = false,
    bool orderByValue = false,
    dynamic startAt,
    dynamic endAt,
    dynamic equalTo,
    int? limitToFirst,
    int? limitToLast,
  }) async {
    _ensureInitialized();

    try {
      final queryRef = _buildQuery(
        path: path,
        orderByChild: orderByChild,
        orderByKey: orderByKey,
        orderByValue: orderByValue,
        startAt: startAt,
        endAt: endAt,
        equalTo: equalTo,
        limitToFirst: limitToFirst,
        limitToLast: limitToLast,
      );

      final snapshot = await queryRef.get();
      return snapshot.exists ? snapshot.value : null;
    } catch (error) {
      RealtimeFirebaseErrorHandler.throwOperationError('Query operation', error);
    }
  }

  String queryListen(
    String path,
    void Function(dynamic data, String? key) onData, {
    String? orderByChild,
    bool orderByKey = false,
    bool orderByValue = false,
    dynamic startAt,
    dynamic endAt,
    dynamic equalTo,
    int? limitToFirst,
    int? limitToLast,
    void Function(Object error)? onError,
    String? listenerId,
  }) {
    _ensureInitialized();

    final id = listenerId ?? 'query_${path}_${DateTime.now().millisecondsSinceEpoch}';

    try {
      final queryRef = _buildQuery(
        path: path,
        orderByChild: orderByChild,
        orderByKey: orderByKey,
        orderByValue: orderByValue,
        startAt: startAt,
        endAt: endAt,
        equalTo: equalTo,
        limitToFirst: limitToFirst,
        limitToLast: limitToLast,
      );

      final subscription = queryRef.onValue.listen(
        (event) {
          final data = event.snapshot.exists ? event.snapshot.value : null;
          onData(data, event.snapshot.key);
        },
        onError: (error) {
          if (onError != null) {
            onError(error);
          }
        },
      );

      _listeners[id] = subscription;
      return id;
    } catch (error) {
      RealtimeFirebaseErrorHandler.throwOperationError('Query listen setup', error);
    }
  }

  Future<void> batchUpdate(Map<String, dynamic> updates) async {
    _ensureInitialized();

    try {
      final timestamped = <String, dynamic>{};
      updates.forEach((path, value) {
        if (value is Map<String, dynamic>) {
          timestamped[path] = {
            ...value,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          };
        } else {
          timestamped[path] = value;
        }
      });

      await _database!.ref().update(timestamped);
    } catch (error) {
      RealtimeFirebaseErrorHandler.throwOperationError('Batch update', error);
    }
  }

  Future<bool> exists(String path) async {
    _ensureInitialized();

    try {
      final snapshot = await _database!.ref(path).get();
      return snapshot.exists;
    } catch (error) {
      RealtimeFirebaseErrorHandler.throwOperationError('Exists check', error);
    }
  }

  String onConnectionState(
    void Function(bool isConnected) callback, {
    String? listenerId,
  }) {
    _ensureInitialized();

    final id = listenerId ?? 'connection_${DateTime.now().millisecondsSinceEpoch}';

    try {
      final subscription = _database!.ref('.info/connected').onValue.listen(
        (event) => callback(event.snapshot.value == true),
        onError: (_) => callback(false),
      );

      _listeners[id] = subscription;
      return id;
    } catch (error) {
      RealtimeFirebaseErrorHandler.throwOperationError(
        'Connection state listener setup',
        error,
      );
    }
  }

  Future<void> dispose() async {
    await unlistenAll();
    _initialized = false;
    _persistenceConfigured = false;
    _database = null;
  }

  Future<T?> runTransaction<T>(
    String path,
    T? Function(T? currentValue) updateFunction,
  ) async {
    _ensureInitialized();

    try {
      final result = await _database!.ref(path).runTransaction((currentData) {
        return Transaction.success(updateFunction(currentData as T?));
      });
      return result.snapshot.value as T?;
    } catch (error) {
      RealtimeFirebaseErrorHandler.throwOperationError('Transaction', error);
    }
  }

  Future<List<String>> pushMultiple(
    String path,
    List<Map<String, dynamic>> items,
  ) async {
    _ensureInitialized();

    try {
      final ref = _database!.ref(path);
      final keys = <String>[];

      for (final item in items) {
        final newRef = ref.push();
        final payload = {
          ...item,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        };
        await newRef.set(payload);
        keys.add(newRef.key!);
      }

      return keys;
    } catch (error) {
      RealtimeFirebaseErrorHandler.throwOperationError('Push multiple', error);
    }
  }

  Future<void> enablePersistence() async {
    await _configurePersistenceIfNeeded();
  }

  void disablePersistence() {
    // Not supported safely after database use.
  }

  DatabaseReference ref(String path) {
    _ensureInitialized();
    return _database!.ref(path);
  }

  Future<void> _configurePersistenceIfNeeded() async {
    if (_database == null || _persistenceConfigured) return;

    try {
      _database!.setPersistenceEnabled(true);
      _persistenceConfigured = true;
    } catch (_) {
      _persistenceConfigured = true;
    }
  }

  Query _buildQuery({
    required String path,
    String? orderByChild,
    bool orderByKey = false,
    bool orderByValue = false,
    dynamic startAt,
    dynamic endAt,
    dynamic equalTo,
    int? limitToFirst,
    int? limitToLast,
  }) {
    Query query = _database!.ref(path);

    if (orderByChild != null) {
      query = query.orderByChild(orderByChild);
    } else if (orderByKey) {
      query = query.orderByKey();
    } else if (orderByValue) {
      query = query.orderByValue();
    }

    if (equalTo != null) {
      query = query.equalTo(equalTo);
    }
    if (startAt != null) {
      query = query.startAt(startAt);
    }
    if (endAt != null) {
      query = query.endAt(endAt);
    }
    if (limitToFirst != null) {
      query = query.limitToFirst(limitToFirst);
    }
    if (limitToLast != null) {
      query = query.limitToLast(limitToLast);
    }

    return query;
  }

  void _ensureInitialized() {
    if (!isInitialized) {
      RealtimeFirebaseErrorHandler.throwNotInitialized();
    }
  }
}
