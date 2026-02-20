import 'package:dartz/dartz.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';

import '../../../../Core/Services/Api/api_endpoints.dart';
import '../../../../Core/Services/Api/api_service.dart';
import '../../../../Core/Services/Firebase/failure_model.dart';
import '../../../../Core/Services/Notifications/notification_model.dart';
import '../../../../Core/Services/Notifications/notification_services.dart';
import '../../../../Core/Utils/Enums/notification_type.dart';
import '../../../../Core/Utils/Models/exam_model.dart';
import '../../../../Core/Utils/Models/subject_model.dart';

class SubjectsRemoteDataSource {
  Future<Either<String, List<ExamModel>>> getExams(String subjectId) async {
    try {
      final response = await DioHelper.getData(
        path: ApiEndpoints.subjectGetExams(subjectId),
      );
      final body = _toMap(response.data);
      final list = body['data'];
      if (list is! List) {
        return const Right(<ExamModel>[]);
      }

      final exams = <ExamModel>[
        for (final item in list)
          ExamModel.fromJson({
            ..._toMap(item),
          }),
      ];

      return Right(exams);
    } catch (error) {
      return Left(error.toString());
    }
  }

  Future<Either<FailureModel, List<SubjectModel>>> getSubjects(
  ) async {
    try {
      final response = await DioHelper.getData(path: ApiEndpoints.subjects);
      final data = response.data as List;
      final list = <SubjectModel>[];
      if (data.isEmpty) {
        return const Right(<SubjectModel>[]);
      }
      for (var element in data) {
        list.add(SubjectModel.fromJson(element));
      }

      return Right(list);
    } catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: '',
        ),
      );
    }
  }

  Future<Either<FailureModel, SubjectModel>> addSubject(String name) async {
    try {
      final response = await DioHelper.postData(
        path: ApiEndpoints.subjectCreate,
        data: {'name': name},
      );

      final ok = response.status;
      if (!ok) {
        return Left(
          FailureModel(
            error: '',
            message: response.message,
          ),
        );
      }
      final body = response.data as Map<String, dynamic>;
      final created = SubjectModel.fromJson(body);

      // await NotificationServices.subscribeToTopic(
      //     created.subscribeToTopicForAdmin);

      return Right(created);
    } catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: DataSourceStrings.subjectCreationError,
        ),
      );
    }
  }

  Future<Either<FailureModel, bool>> updateSubject(SubjectModel model) async {
    try {
      final response = await DioHelper.putData(
        path: ApiEndpoints.subjectUpdateStatus(model.subjectId),
        data: {
          'status': model.subjectIsOpen ? 'active' : 'closed',
        },
      );
      final ok =
          (response.statusCode ?? 0) >= 200 && (response.statusCode ?? 0) < 300;
      if (!ok) {
        return Left(_toFailure(_toMap(response.data)));
      }
      return const Right(true);
    } catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: '',
        ),
      );
    }
  }

  Future<Either<FailureModel, bool>> deleteSubjectCompletely(
    SubjectModel model,
  ) async {
    try {
      final response = await DioHelper.deleteData(
        path: ApiEndpoints.subjectRemove(model.subjectId),
      );
      final ok =
          (response.statusCode ?? 0) >= 200 && (response.statusCode ?? 0) < 300;
      if (!ok) {
        return Left(_toFailure(_toMap(response.data)));
      }
      // await NotificationServices.unSubscribeToTopic(
      //     model.subscribeToTopicForAdmin);

      await NotificationServices.unSubscribeToTopic(
          model.subscribeToTopicForMembers);
      return const Right(true);
    } catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: '',
        ),
      );
    }
  }

  Future<Either<FailureModel, bool>> toggleSubjectOpen(
    SubjectModel model,
    bool isOpen,
  ) async {
    try {
      final response = await DioHelper.putData(
        path: ApiEndpoints.subjectUpdateStatus(model.subjectId),
        data: {'status': isOpen ? 'active' : 'closed'},
      );
      final ok =
          (response.statusCode ?? 0) >= 200 && (response.statusCode ?? 0) < 300;
      if (!ok) {
        return Left(_toFailure(_toMap(response.data)));
      }
      return const Right(true);
    } catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: '',
        ),
      );
    }
  }

  Future<Either<FailureModel, bool>> leaveSubject(
    SubjectModel model,
    String studentEmail,
  ) async {
    return Left(
      FailureModel(
        error: 'not_supported',
        message: 'Leave subject is not supported by current API yet',
      ),
    );
  }

  Future<Either<FailureModel, SubjectModel>> joinSubject(
    String code,
    String email,
    String name,
  ) async {
    try {
      final response = await DioHelper.postData(
        path: ApiEndpoints.subjectJoin,
        data: {'code': code},
      );
      final body = _toMap(response.data);
      final ok = response.status;
      if (!ok) {
        return Left(_toFailure(body));
      }

      final data = SubjectModel.fromJson(_toMap(body['data']));
      await NotificationServices.subscribeToTopic(
          data.subscribeToTopicForMembers);

      final notification = NotificationModel(
        topicId: '',
        type: NotificationType.joinedSubject,
        body: DataSourceStrings.subjectJoinedBody(
          name,
          data.subjectName,
          4,
        ),
      );
      await NotificationServices.sendNotificationToTopic(
        id: '${AppConstants.joinedSubjectNotificationPrefix}${data.subjectId}',
        data: notification.toJson(),
        stringData: notification.toJsonString(),
      );
      return Right(data);
    } catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: '',
        ),
      );
    }
  }

  FailureModel _toFailure(Map<String, dynamic> body) {
    return FailureModel(
      error: body,
      message: body['message']?.toString() ?? 'Request failed',
    );
  }

  Map<String, dynamic> _toMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }
}
