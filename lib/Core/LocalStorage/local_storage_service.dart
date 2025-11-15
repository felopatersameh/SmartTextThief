import 'package:hive/hive.dart';
import 'local_storage_keys.dart';

class LocalStorageService {
  static late Box _box;

  static Future<void> init() async =>
      _box = await Hive.openBox(LocalStorageKeys.boxName);

  static Future<void> setValue(String key, dynamic value) async =>
      await _box.put(key, value);

  static dynamic getValue(String key, {dynamic defaultValue}) =>
      _box.get(key, defaultValue: defaultValue);

  static Future<void> removeValue(String key) async => await _box.delete(key);

  static Future<void> clear() async => await _box.clear();
}
