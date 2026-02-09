import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../Core/LocalStorage/get_local_storage.dart';
import '../../../Core/Resources/resources.dart';
import '../../../Core/Utils/Models/data_model.dart';
import '../../../Core/Services/Firebase/analysis_data.dart';
import '../../../Core/Services/Firebase/failure_model.dart';
import '../../../Core/Services/Firebase/firebase_service.dart';
import '../../../Core/Services/Notifications/notification_services.dart';
import '../../../Core/Utils/Enums/collection_key.dart';
import '../../../Core/Utils/Enums/data_key.dart';
import '../../../Core/Utils/Models/user_model.dart';

class ProfileSource {
  static Future<Either<FailureModel, (UserModel, List<DataModel>)>>
      getDataUser() async {
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

  static Future<Either<FailureModel, bool>> updateGeminiApiKey(
    String geminiApiKey,
  ) async {
    try {
      final String userId = GetLocalStorage.getIdUser();
      final response = await FirebaseServices.instance.updateData(
        CollectionKey.users.key,
        userId,
        {DataKey.userGeminiApiKey.key: geminiApiKey},
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

  static Future<Either<FailureModel, bool>> deleteCurrentUserData() async {
    try {
      final String userId = GetLocalStorage.getIdUser();
      if (userId.isEmpty) {
        return Left(
          FailureModel(
            error: "empty_user_id",
            message: "User id is missing",
          ),
        );
      }

      final response = await FirebaseServices.instance.getData(
        userId,
        CollectionKey.users.key,
      );
      if (!response.status || response.data == null) {
        return Left(
          FailureModel(
            error: response.failure?.error.toString(),
            message: response.message,
          ),
        );
      }

      final user = UserModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      await _clearNotificationTopicsExceptAllUsers(user.subscribedTopics,user.isTe);

      if (user.isTe) {
        await _deleteTeacherSubjects(user.userEmail);
      } else {
        await _removeStudentFromAllSubjects(user.userEmail);
      }

      final removeUserResponse = await FirebaseServices.instance.removeData(
        CollectionKey.users.key,
        user.userId,
      );
      if (!removeUserResponse.status) {
        return Left(
          FailureModel(
            error: removeUserResponse.failure?.error.toString(),
            message: removeUserResponse.message,
          ),
        );
      }
      return right(true);
    } catch (error) {
      return Left(
        FailureModel(
          error: error.toString(),
          message: "Failed to delete user data",
        ),
      );
    }
  }

  static Future<void> _clearNotificationTopicsExceptAllUsers(
    List<String> topics,
    bool isTe,
  ) async {
    final filteredTopics = topics
        .map((topic) => topic.trim())
        .where((topic) => topic.isNotEmpty && topic != AppConstants.allUsersTopic)
        .toSet()
        .toList();

    for (final topic in filteredTopics) {
      await NotificationServices.unSubscribeToTopic(topic);
    }

    if (!isTe) return;

    final topicsToDeleteNotifications = <String>{};
    for (final topic in filteredTopics) {
      final baseTopic = topic.endsWith(AppConstants.adminTopicSuffix)
          ? topic.substring(
              0,
              topic.length - AppConstants.adminTopicSuffix.length,
            )
          : topic;
      if (baseTopic.isEmpty) continue;

      topicsToDeleteNotifications.add(baseTopic);
      topicsToDeleteNotifications.add(
        '$baseTopic${AppConstants.adminTopicSuffix}',
      );
    }

    await _deleteNotificationsByTopics(topicsToDeleteNotifications);
  }

  static Future<void> _deleteNotificationsByTopics(Set<String> topics) async {
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

  static Future<void> _deleteTeacherSubjects(String teacherEmail) async {
    final response = await FirebaseServices.instance.findDocsByField(
      CollectionKey.subjects.key,
      teacherEmail,
      nameField: "${DataKey.subjectTeacher.key}.${DataKey.teacherEmail.key}",
    );

    if (!response.status || response.data == null) {
      return;
    }

    final subjects = (response.data as List)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    for (final subject in subjects) {
      final subjectId = (subject[DataKey.subjectIdSubject.key] ?? "").toString();
      if (subjectId.isEmpty) continue;

      await _deleteAllExamsInSubject(subjectId);

      await FirebaseServices.instance.removeData(
        CollectionKey.subjects.key,
        subjectId,
      );
    }
  }

  static Future<void> _removeStudentFromAllSubjects(String studentEmail) async {
    final response = await FirebaseServices.instance.findDocsInList(
      CollectionKey.subjects.key,
      studentEmail,
      nameField: DataKey.subjectEmailSts.key,
    );

    if (!response.status || response.data == null) {
      return;
    }

    final subjects = (response.data as List)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    for (final subject in subjects) {
      final subjectId = (subject[DataKey.subjectIdSubject.key] ?? "").toString();
      if (subjectId.isEmpty) continue;

      await FirebaseServices.instance.updateData(
        CollectionKey.subjects.key,
        subjectId,
        {
          DataKey.subjectEmailSts.key: FieldValue.arrayRemove([studentEmail]),
        },
      );

      await _removeStudentResultsFromExams(
        subjectId: subjectId,
        studentEmail: studentEmail,
      );
    }
  }

  static Future<void> _deleteAllExamsInSubject(String subjectId) async {
    final response = await FirebaseServices.instance.getAllData(
      CollectionKey.subjects.key,
      subjectId,
      subCollections: [CollectionKey.exams.key],
    );
    if (!response.status || response.data == null) {
      return;
    }

    final exams = (response.data as List)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    for (final exam in exams) {
      final examId = (exam[DataKey.examId.key] ?? "").toString();
      if (examId.isEmpty) continue;
      await FirebaseServices.instance.removeData(
        CollectionKey.subjects.key,
        subjectId,
        subCollections: [CollectionKey.exams.key],
        subIds: [examId],
      );
    }
  }

  static Future<void> _removeStudentResultsFromExams({
    required String subjectId,
    required String studentEmail,
  }) async {
    final response = await FirebaseServices.instance.getAllData(
      CollectionKey.subjects.key,
      subjectId,
      subCollections: [CollectionKey.exams.key],
    );
    if (!response.status || response.data == null) {
      return;
    }

    final exams = (response.data as List)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    for (final exam in exams) {
      final examId = (exam[DataKey.examId.key] ?? "").toString();
      if (examId.isEmpty) continue;

      final rawResults = exam[DataKey.examExamResult.key];
      if (rawResults is! List) continue;

      final filteredResults = rawResults.where((resultItem) {
        if (resultItem is Map<String, dynamic>) {
          return resultItem[DataKey.examResultEmailSt.key] != studentEmail;
        }
        if (resultItem is Map) {
          return resultItem[DataKey.examResultEmailSt.key] != studentEmail;
        }
        return true;
      }).toList();

      if (filteredResults.length == rawResults.length) continue;

      await FirebaseServices.instance.updateData(
        CollectionKey.subjects.key,
        subjectId,
        {
          DataKey.examExamResult.key: filteredResults,
        },
        subCollections: [CollectionKey.exams.key],
        subIds: [examId],
      );
    }
  }
}
