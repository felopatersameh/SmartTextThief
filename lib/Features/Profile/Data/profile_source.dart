import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:smart_text_thief/Core/LocalStorage/local_storage_keys.dart';
import 'package:smart_text_thief/Core/LocalStorage/local_storage_service.dart';
import 'package:smart_text_thief/Core/Utils/Enums/enum_user.dart';
import '../../../Core/Services/Api/api_endpoints.dart';
import '../../../Core/Services/Api/api_response_model.dart';
import '../../../Core/Services/Api/api_service.dart';
import '../../../Core/Services/Firebase/failure_model.dart';
import '../../../Core/Utils/Enums/data_key.dart';
import '../../../Core/Utils/Models/data_model.dart';
import '../../../Core/Utils/Models/user_model.dart';

class ProfileSource {
  static Future<Either<FailureModel, (UserModel, List<DataModel>)>>
      getDataUser() async {
    try {
      final response = await Future.wait(
          [DioHelper.getData(path: ApiEndpoints.userProfile), analyzeUser()]);
      final model = UserModel.fromJson(
          (response[0] as ApiResponseModel<dynamic>).data
              as Map<String, dynamic>);
      await LocalStorageService.setValue(
          LocalStorageKeys.email, model.userEmail);
      await LocalStorageService.setValue(LocalStorageKeys.name, model.userName);
      await LocalStorageService.setValue(
          LocalStorageKeys.role, model.userType.value);
      final analysis = response[1] as List<DataModel>;
      return Right((model, analysis));
    } on DioException catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: 'Failed Get Information',
        ),
      );
    } catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: "",
        ),
      );
    }
  }

  static Future<List<DataModel>> analyzeUser() async {
    final response = await DioHelper.getData(path: ApiEndpoints.userDashboard);
    if (!response.status) {
      return [];
    }
    final model =
        (response.data as List).map((e) => DataModel.fromJson(e)).toList();

    return (model);
  }

  static Future<Either<FailureModel, bool>> updateType(String type) async {
    try {
      final role = UserType.fromString(type);
      if (role == UserType.non) {
        return const Right(false);
      }
      final response = await DioHelper.postData(
        path: ApiEndpoints.userSubmitRole,
        data: {DataKey.role.key: role.value},
      );
      if (!response.status) {
        return Left(
          FailureModel(
            error: '',
            message: response.message,
          ),
        );
      }
      await getDataUser();
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

  static Future<Either<FailureModel, bool>> deleteCurrentUserData() async {
    try {
      final response =
          await DioHelper.deleteData(path: ApiEndpoints.userRemove);
      if (!response.status) {
        return Left(
          FailureModel(
            error: response.data.toString(),
            message: response.message.isNotEmpty
                ? response.message
                : 'Failed to delete user data',
          ),
        );
      }
      return const Right(true);
    } catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: "Failed to delete user data",
        ),
      );
    }
  }

  static bool isRoleNotChosenError(String message) {
    return message.contains('You must choose your role first') ||
        (message.contains('role') && message.contains('choose'));
  }
}
