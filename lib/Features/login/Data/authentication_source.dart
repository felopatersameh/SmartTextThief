import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smart_text_thief/Core/Services/Device/device_info_service.dart';
import 'package:smart_text_thief/Core/Utils/Enums/data_key.dart';

import '../../../Config/env_config.dart';
import '../../../Core/LocalStorage/local_storage_keys.dart';
import '../../../Core/LocalStorage/local_storage_service.dart';
import '../../../Core/Services/Api/api_endpoints.dart';
import '../../../Core/Services/Api/api_service.dart';
import '../../../Core/Services/Error/failure_model.dart';

class AuthenticationSource {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static Future<Either<FailureModel, bool>> loginWithGoogle() async {
    try {
      final webClientId = EnvConfig.googleWebClientId;
      await _googleSignIn.initialize(
        clientId: webClientId.isEmpty ? null : webClientId,
      );
      final account = await _googleSignIn.authenticate();
      final payload = await _buildGooglePayload(account);

      final response = await DioHelper.postData(
        path: ApiEndpoints.authGoogle,
        data: payload,
      );
      final body = response.data as Map<String, dynamic>;
      final token = body[DataKey.token.key];
      if (token.isEmpty) {
        return Left(
          FailureModel(
            error: body,
            message: response.message,
          ),
        );
      }
      //* then here auth success
      await LocalStorageService.setValue(LocalStorageKeys.token, token);
      await LocalStorageService.setValue(LocalStorageKeys.isLoggedIn, true);

      return const Right(true);
    } catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: "",
        ),
      );
    }
  }

  static Future<void> logout() async {
    try {
      await DioHelper.postData(path: ApiEndpoints.userLogout);
    } catch (_) {}

    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    LocalStorageService.clear();
  }

  static Future<Map<String, dynamic>> _buildGooglePayload(
    GoogleSignInAccount account,
  ) async {
    final deviceInfo = await DeviceInfoService.getDeviceInfo();
    return {
      'deviceId': deviceInfo.$2,
      'deviceInfo': deviceInfo.$1,
      'clientProfile': {
        'googleId': account.id,
        'email': account.email,
        'name': account.displayName ?? '',
        'photoUrl': account.photoUrl ?? '',
      },
    };
  }
}
