import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:smart_text_thief/Core/Storage/Firebase/firebase_service.dart';
import 'package:smart_text_thief/Core/Utils/Enums/collection_key.dart';
import 'package:smart_text_thief/Core/Utils/Enums/data_key.dart';
import 'package:smart_text_thief/Core/Utils/Enums/enum_user.dart';
import 'package:smart_text_thief/Core/Utils/Models/user_model.dart';

import '../../../Core/Storage/Firebase/failure_model.dart';
import '../../../Core/Storage/Local/local_storage_keys.dart';
import '../../../Core/Storage/Local/local_storage_service.dart';

class AuthenticationSource {
  static Future<bool> checkIsHave(String email) async {
    final checkIs = await FirebaseServices.instance.checkIsExists(
      DataKey.userEmail.key,
      CollectionKey.users.key,
      email,
    );
    return checkIs.status;
  }

  static Future<Either<FailureModel, bool>> loginWithGoogle() async {
    try {
      final account = await FirebaseServices.instance.google();
      log(account.toString());
      final isExist = await checkIsHave(account.email);
      if (isExist == false) {
        final fcm = await LocalStorageService.getValue(
          LocalStorageKeys.tokenFCM,
          defaultValue: "",
        );
        final UserModel model = UserModel(
          userId: account.id,
          userTokensFcm: [fcm],
          userName: account.displayName.toString(),
          userEmail: account.email,
          photo: account.photoUrl??"",
          userPassword: '',
          userPhone: '',
          userType: UserType.st,
          userNotifications: [],
          userCreatedAt: DateTime.now()
        );

        final response = await FirebaseServices.instance.createAccount(
          model.toJson(),
          model.userId,
        );
        if (response.data == null) return Left(response.failure!);
      }
      await LocalStorageService.setValue(LocalStorageKeys.id, account.id);
      await LocalStorageService.setValue(LocalStorageKeys.isLoggedIn, true);
      return Right(true);
    } catch (error) {
      final FailureModel model = FailureModel(
        error: error.toString(),
        message: "",
      );
      return Left(model);
    }
  }
}
