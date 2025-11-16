import 'package:dartz/dartz.dart';
import '../../../Core/LocalStorage/get_local_storage.dart';
import '../../../Core/Utils/Models/data_model.dart';
import '../../../Core/Services/Firebase/analysis_data.dart';
import '../../../Core/Services/Firebase/failure_model.dart';
import '../../../Core/Services/Firebase/firebase_service.dart';
import '../../../Core/Services/Notifications/notification_services.dart';
import '../../../Core/Utils/Enums/collection_key.dart';
import '../../../Core/Utils/Enums/data_key.dart';
import '../../../Core/Utils/Models/user_model.dart';

class ProfileSource {
  static Future<Either<FailureModel, (UserModel, List<DataModel>)>> getDataUser() async {
    try {
      final String userId = GetLocalStorage.getIdUser();

      final response = await FirebaseServices.instance.getData(
        userId,
        CollectionKey.users.key,
      );

      final Map<String, dynamic> data = response.data;
      final UserModel userModel = UserModel.fromJson(data);

      for (var topic in userModel.subscribedTopics) {
        await NotificationServices.subscribeToTopic(topic);
      }

      final List<DataModel> analysis = await _analyzeUser(userModel);

      return Right((userModel, analysis));
    } catch (error) {
      final FailureModel model = FailureModel(
        error: error.toString(),
        message: "",
      );
      return Left(model);
    }
  }

  static Future<List<DataModel>> _analyzeUser(UserModel model) async {
    final String email = model.userEmail;

    if (email.isEmpty) return [];

    if (model.isTe == true) {
      return await AnalysisData.analyzedInstructor(email: email);
    } else {
      return await AnalysisData.analyzedStudent(email: email);
    }
  }

  static Future<Either<FailureModel, bool>> updateType(String type) async {
    try {
      final String userId = GetLocalStorage.getIdUser();
      final response = await FirebaseServices.instance.updateData(
        CollectionKey.users.key,
        userId,
        {DataKey.userType.key: type},
      );
      if (!response.status) return right(false);
      return right(true);
    } catch (error) {
      final FailureModel model = FailureModel(
        error: error.toString(),
        message: "",
      );
      return Left(model);
    }
  }
}
