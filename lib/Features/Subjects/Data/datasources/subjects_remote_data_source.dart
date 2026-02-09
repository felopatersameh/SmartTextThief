import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';

import '../../../../Core/LocalStorage/get_local_storage.dart';
import '../../../../Core/Services/Firebase/failure_model.dart';
import '../../../../Core/Services/Firebase/firebase_service.dart';
import '../../../../Core/Services/Firebase/response_model.dart';
import '../../../../Core/Services/Notifications/notification_model.dart';
import '../../../../Core/Services/Notifications/notification_services.dart';
import '../../../../Core/Utils/Enums/collection_key.dart';
import '../../../../Core/Utils/Enums/data_key.dart';
import '../../../../Core/Utils/Enums/notification_type.dart';
import '../../../../Core/Utils/Models/exam_model.dart';
import '../../../../Core/Utils/Models/subject_model.dart';

class SubjectsRemoteDataSource {
  Future<Either<String, List<ExamModel>>> getExams(String subjectId) async {
    try {
      final response = await FirebaseServices.instance.getAllData(
        CollectionKey.subjects.key,
        subjectId,
        subCollections: [CollectionKey.exams.key],
      );
      if (!response.status) {
        return left(response.message);
      }

      final exams = <ExamModel>[
        for (final item in (response.data as List<dynamic>))
          ExamModel.fromJson(Map<String, dynamic>.from(item as Map)),
      ]..sort((a, b) => b.examCreatedAt.compareTo(a.examCreatedAt));

      return right(exams);
    } catch (error) {
      return left(error.toString());
    }
  }

  Future<Either<FailureModel, List<SubjectModel>>> getSubjects(
    String email,
    bool isStudent,
  ) async {
    ResponseModel response;
    try {
      if (isStudent) {
        response = await FirebaseServices.instance.findDocsInList(
          CollectionKey.subjects.key,
          email,
          nameField: DataKey.subjectEmailSts.key,
        );
      } else {
        response = await FirebaseServices.instance.findDocsByField(
          CollectionKey.subjects.key,
          email,
          nameField:
              '${DataKey.subjectTeacher.key}.${DataKey.teacherEmail.key}',
        );
      }

      final subjects = <SubjectModel>[
        if (response.status)
          for (final item in (response.data as List<dynamic>))
            SubjectModel.fromJson(Map<String, dynamic>.from(item as Map)),
      ]..sort((a, b) => a.subjectCreatedAt.compareTo(b.subjectCreatedAt));

      return right(subjects);
    } catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: '',
        ),
      );
    }
  }

  Future<Either<FailureModel, String>> addSubject(SubjectModel model) async {
    try {
      final response = await FirebaseServices.instance.addData(
        CollectionKey.subjects.key,
        model.subjectId,
        model.toJson(),
      );
      if (!response.status) {
        return Left(_toFailure(response));
      }

      await NotificationServices.subscribeToTopic(model.subscribeToTopicForAdmin);
      return right(model.subjectName);
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
      final response = await FirebaseServices.instance.updateData(
        CollectionKey.subjects.key,
        model.subjectId,
        model.toJson(),
      );
      if (!response.status) {
        return Left(_toFailure(response));
      }
      return right(true);
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
      await _deleteAllExamsInSubject(model.subjectId);
      await _deleteNotificationsByTopics({
        model.subscribeToTopicForMembers,
        model.subscribeToTopicForAdmin,
      });
      await _removeTopicsFromAllUsers({
        model.subscribeToTopicForMembers,
        model.subscribeToTopicForAdmin,
      });
      await NotificationServices.unSubscribeToTopic(model.subscribeToTopicForAdmin);
      await NotificationServices.unSubscribeToTopic(
        model.subscribeToTopicForMembers,
      );

      final response = await FirebaseServices.instance.removeData(
        CollectionKey.subjects.key,
        model.subjectId,
      );
      if (!response.status) {
        return Left(_toFailure(response));
      }
      return right(true);
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
      final response = await FirebaseServices.instance.updateData(
        CollectionKey.subjects.key,
        model.subjectId,
        {DataKey.subjectIsOpen.key: isOpen},
      );
      if (!response.status) {
        return Left(_toFailure(response));
      }
      return right(true);
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
    try {
      final response = await FirebaseServices.instance.updateData(
        CollectionKey.subjects.key,
        model.subjectId,
        {
          DataKey.subjectEmailSts.key: FieldValue.arrayRemove([studentEmail]),
        },
      );
      if (!response.status) {
        return Left(_toFailure(response));
      }

      await NotificationServices.unSubscribeToTopic(model.subscribeToTopicForMembers);
      await _removeTopicFromCurrentUser(model.subscribeToTopicForMembers);
      return right(true);
    } catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: '',
        ),
      );
    }
  }

  Future<Either<FailureModel, SubjectModel>> joinSubject(
    String code,
    String email,
    String name,
  ) async {
    try {
      final exists = await FirebaseServices.instance.checkIsExists(
        DataKey.subjectCodeSub.key,
        CollectionKey.subjects.key,
        code,
      );
      if (!exists.status) {
        return Left(
          FailureModel(
            error: exists.failure?.error.toString(),
            message: DataSourceStrings.invalidSubjectCode,
          ),
        );
      }

      final subjectId = exists.data.toString();
      final beforeJoinResult = await FirebaseServices.instance.getData(
        subjectId,
        CollectionKey.subjects.key,
      );
      if (!beforeJoinResult.status || beforeJoinResult.data == null) {
        return Left(_toFailure(beforeJoinResult));
      }

      final subjectBeforeJoin = SubjectModel.fromJson(
        Map<String, dynamic>.from(beforeJoinResult.data as Map),
      );
      if (!subjectBeforeJoin.subjectIsOpen) {
        return Left(
          FailureModel(
            error: AppConstants.subjectClosedErrorCode,
            message: DataSourceStrings.subjectClosed,
          ),
        );
      }
      if (subjectBeforeJoin.subjectEmailSts.contains(email)) {
        return right(subjectBeforeJoin);
      }

      final updateResult = await FirebaseServices.instance.updateData(
        CollectionKey.subjects.key,
        subjectId,
        {
          DataKey.subjectEmailSts.key: FieldValue.arrayUnion([email]),
        },
      );
      if (!updateResult.status) {
        return Left(_toFailure(updateResult));
      }

      final response = await FirebaseServices.instance.getData(
        subjectId,
        CollectionKey.subjects.key,
      );
      if (!response.status || response.data == null) {
        return Left(_toFailure(response));
      }

      final data = SubjectModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
      await NotificationServices.subscribeToTopic(data.subscribeToTopicForMembers);

      final notification = NotificationModel(
        topicId: data.subscribeToTopicForAdmin,
        type: NotificationType.joinedSubject,
        body: DataSourceStrings.subjectJoinedBody(
          name,
          data.subjectName,
          data.subjectEmailSts.length,
        ),
      );
      await NotificationServices.sendNotificationToTopic(
        id: '${AppConstants.joinedSubjectNotificationPrefix}${data.subjectId}',
        data: notification.toJson(),
        stringData: notification.toJsonString(),
      );
      return right(data);
    } catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: '',
        ),
      );
    }
  }

  Future<void> _deleteAllExamsInSubject(String subjectId) async {
    final response = await FirebaseServices.instance.getAllData(
      CollectionKey.subjects.key,
      subjectId,
      subCollections: [CollectionKey.exams.key],
    );
    if (!response.status || response.data == null) return;

    final exams = (response.data as List<dynamic>)
        .whereType<Map>()
        .map((exam) => Map<String, dynamic>.from(exam))
        .toList();

    for (final exam in exams) {
      final examId = (exam[DataKey.examId.key] ?? '').toString();
      if (examId.isEmpty) continue;
      await FirebaseServices.instance.removeData(
        CollectionKey.subjects.key,
        subjectId,
        subCollections: [CollectionKey.exams.key],
        subIds: [examId],
      );
    }
  }

  Future<void> _deleteNotificationsByTopics(Set<String> topics) async {
    for (final topic in topics) {
      final snapshot = await FirebaseFirestore.instance
          .collection(CollectionKey.notification.key)
          .where(DataKey.topicId.key, isEqualTo: topic)
          .get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  Future<void> _removeTopicsFromAllUsers(Set<String> topics) async {
    for (final topic in topics) {
      final users = await FirebaseFirestore.instance
          .collection(CollectionKey.users.key)
          .where(DataKey.subscribedTopics.key, arrayContains: topic)
          .get();
      for (final userDoc in users.docs) {
        await userDoc.reference.update({
          DataKey.subscribedTopics.key: FieldValue.arrayRemove([topic]),
        });
      }
    }
  }

  Future<void> _removeTopicFromCurrentUser(String topic) async {
    final userId = GetLocalStorage.getIdUser();
    if (userId.isEmpty) return;
    await FirebaseServices.instance.updateData(
      CollectionKey.users.key,
      userId,
      {
        DataKey.subscribedTopics.key: FieldValue.arrayRemove([topic]),
      },
    );
  }

  FailureModel _toFailure(ResponseModel response) {
    return FailureModel(
      error: response.failure?.error.toString(),
      message: response.message,
    );
  }
}
