import 'package:smart_text_thief/Core/Storage/Local/local_storage_keys.dart';
import 'package:smart_text_thief/Core/Storage/Local/local_storage_service.dart';

class GetLocalStorge{
   static String getidUser() =>
      LocalStorageService.getValue(LocalStorageKeys.id, defaultValue: ""); 
        static String getemailUser() =>
      LocalStorageService.getValue(LocalStorageKeys.email, defaultValue: "");
}