import 'package:dartz/dartz.dart';
import '../../../../Core/Resources/resources.dart';
import '../../../../Core/Services/Api/api_endpoints.dart';
import '../../../../Core/Services/Api/api_service.dart';
import '../../../../Core/Services/Error/failure_model.dart';
import '../../../../Core/Services/Notifications/notification_services.dart';
import '../../../../Core/Utils/Enums/data_key.dart';
import '../../../../Core/Utils/Models/subject_model.dart';
import 'package:smart_text_thief/Features/Exams/shared/Models/exam_model.dart';

import '../../../Exams/shared/Models/Analytics/analytics_model.dart';

class SubjectsRemoteDataSource {
  Future<Either<String, List<ExamModel>>> getExams(String subjectId) async {
    try {
      final response = await DioHelper.getData(
        path: ApiEndpoints.subjectGetExams(subjectId),
      );
      if (!response.status) {
        return Left(response.message);
      }
      final exams = ((response.data ?? []) as List)
          .map((e) => ExamModel.fromJson(e))
          .toList();
      return Right(exams);
    } catch (error) {
      return Left(error.toString());
    }
  }

  Future<Either<String, AnalyticsSubjectModel>> getAnalyticsSubjects(
      String subjectId) async {
    try {
      final response = await DioHelper.getData(
        path: ApiEndpoints.subjectGetAnalytics(subjectId),
      );
      if (!response.status) {
        return Left(response.message);
      }
      final exams =
          AnalyticsSubjectModel.fromJson(response.data as Map<String, dynamic>);
      return Right(exams);
    } catch (error) {
      return Left(error.toString());
    }
  }

  Future<Either<FailureModel, List<SubjectModel>>> getSubjects() async {
    try {
      final response = await DioHelper.getData(path: ApiEndpoints.subjects);
      final data = response.data as List;
      if (data.isEmpty) return const Right(<SubjectModel>[]);
      final list = data.map((e) => SubjectModel.fromJson(e)).toList();
      return Right(list);
    } catch (error) {
      return Left(
          FailureModel(error: error.toString(), message: error.toString()));
    }
  }

  Future<Either<FailureModel, SubjectModel>> addSubject(String name) async {
    try {
      final response = await DioHelper.postData(
        path: ApiEndpoints.subjectCreate,
        data: {DataKey.name.key: name},
      );
      if (!response.status) {
        return Left(FailureModel(error: '', message: response.message));
      }
      final created =
          SubjectModel.fromJson(response.data as Map<String, dynamic>);
      await NotificationServices.subscribeToTopic(created.topicID);
      return Right(created);
    } catch (error) {
      return Left(FailureModel(
        error: error.toString(),
        message: DataSourceStrings.subjectCreationError,
      ));
    }
  }

  Future<Either<FailureModel, bool>> deleteSubjectCompletely(
    SubjectModel model,
  ) async {
    try {
      final response = await DioHelper.deleteData(
        path: ApiEndpoints.subjectRemove(model.subjectId),
      );
      if (!response.status) {
        return Left(FailureModel(error: '', message: response.message));
      }
      await NotificationServices.unSubscribeToTopic(
        model.topicID,
      );
      return const Right(true);
    } catch (error) {
      return Left(
          FailureModel(error: error.toString(), message: error.toString()));
    }
  }

  Future<Either<FailureModel, bool>> toggleSubjectOpen(
    SubjectModel model,
    bool isOpen,
  ) async {
    try {
      final response = await DioHelper.putData(
        path: ApiEndpoints.subjectUpdateStatus(model.subjectId),
        data: {DataKey.status.key: isOpen ? 'active' : 'closed'},
      );
      if (!response.status) {
        return Left(FailureModel(error: '', message: response.message));
      }
      return const Right(true);
    } catch (error) {
      return Left(
          FailureModel(error: error.toString(), message: error.toString()));
    }
  }

  Future<Either<FailureModel, bool>> leaveSubject(
    SubjectModel model,
    String studentEmail,
  ) async {
    try {
      final response = await DioHelper.postData(
        path: ApiEndpoints.subjectLeave(model.subjectId),
      );
      if (!response.status) {
        return Left(FailureModel(error: '', message: response.message));
      }
      await NotificationServices.unSubscribeToTopic(model.topicID);
      return const Right(true);
    } catch (error) {
      return Left(
        FailureModel(error: error.toString(), message: error.toString()),
      );
    }
  }

  Future<Either<FailureModel, SubjectModel>> joinSubject(
    String code,
    String email,
    String name,
  ) async {
    try {
      final response = await DioHelper.postData(
        path: ApiEndpoints.subjectJoin,
        data: {DataKey.code.key: code},
      );
      if (!response.status) {
        return Left(FailureModel(error: '', message: response.message));
      }
      final data = SubjectModel.fromJson(response.data as Map<String, dynamic>);
      await NotificationServices.subscribeToTopic(
        data.topicID,
      );
      return Right(data);
    } catch (error) {
      return Left(
          FailureModel(error: error.toString(), message: error.toString()));
    }
  }
}
