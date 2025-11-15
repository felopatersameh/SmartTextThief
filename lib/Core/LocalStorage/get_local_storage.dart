import 'local_storage_keys.dart';
import 'local_storage_service.dart';

class GetLocalStorage {
  static String getIdUser() =>
      LocalStorageService.getValue(LocalStorageKeys.id, defaultValue: "");
  static String getEmailUser() =>
      LocalStorageService.getValue(LocalStorageKeys.email, defaultValue: "");  
      static String getNameUser() =>
      LocalStorageService.getValue(LocalStorageKeys.name, defaultValue: "");
}
