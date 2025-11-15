import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../Core/Services/Firebase/failure_model.dart';
import '../../../Core/Services/Firebase/firebase_service.dart';
import '../../../Core/LocalStorage/local_storage_keys.dart';
import '../../../Core/LocalStorage/local_storage_service.dart';
import '../../../Core/Utils/Enums/collection_key.dart';
import '../../../Core/Utils/Enums/data_key.dart';
import '../../../Core/Utils/Enums/enum_user.dart';
import '../../../Core/Utils/Models/user_model.dart';

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
      final isExist = await checkIsHave(account.email);
      final fcm = await LocalStorageService.getValue(
        LocalStorageKeys.tokenFCM,
        defaultValue: "",
      );
      if (isExist == false) {
        final UserModel model = UserModel(
          userId: account.id,
          userTokensFcm: [fcm],
          userName: account.displayName.toString(),
          userEmail: account.email,
          photo: account.photoUrl ?? "",
          userPassword: '',
          userPhone: '',
          userType: UserType.te,
          userCreatedAt: DateTime.now(),
          subscribedTopics: ["allUsers"]
        );

        final response = await FirebaseServices.instance.createAccount(
          model.toJson(),
          model.userId,
        );
        if (response.data == null) return Left(response.failure!);
      }
      await FirebaseServices.instance.updateData(
        CollectionKey.users.key,
        account.id,
        {
          DataKey.userTokensFCM.key: FieldValue.arrayUnion([fcm]),
        },
      );
      await LocalStorageService.setValue(LocalStorageKeys.id, account.id);
      await LocalStorageService.setValue(LocalStorageKeys.isLoggedIn, true);
      await LocalStorageService.setValue(LocalStorageKeys.email, account.email);
      await LocalStorageService.setValue(
        LocalStorageKeys.name,
        account.displayName,
      );
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
