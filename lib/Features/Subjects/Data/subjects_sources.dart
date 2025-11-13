import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:smart_text_thief/Core/Utils/Enums/notification_type.dart';
import 'package:smart_text_thief/Core/Utils/Models/notification_model.dart';
import '../../../Core/Services/Notifications/notification_services.dart';
import '../../../Core/Utils/Enums/data_key.dart';
import '../../../Core/Services/Firebase/firebase_service.dart';
import '../../../Core/Services/Firebase/response_model.dart';
import '../../../Core/Utils/Enums/collection_key.dart';
import '../../../Core/Utils/Models/exam_model.dart';
import '../../../Core/Utils/Models/subject_model.dart';

import '../../../Core/Services/Firebase/failure_model.dart';

class SubjectsSources {
  static Future<Either<String, List<ExamModel>>> getExam(
    String idSubject,
  ) async {
    try {
      final response = await FirebaseServices.instance.getAllData(
        CollectionKey.subjects.key,
        idSubject,
        subCollections: [CollectionKey.exams.key],
      );
      final List<ExamModel> model = [];
      if (response.status) {
        for (var element in response.data as List) {
          model.add(ExamModel.fromJson(element));
        }

        return right(model);
      } else {
        return left(response.message);
      }
    } catch (e) {
      return left(e.toString());
    }
  }

  static Future<Either<FailureModel, List<SubjectModel>>> getSubjects(
    String email,
    bool array,
  ) async {
    ResponseModel response;
    try {
      if (array) {
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
              "${DataKey.subjectTeacher.key}.${DataKey.teacherEmail.key}",
        );
      }

      final List<SubjectModel> model = [];
      if (response.status == true) {
        final data = response.data as List;
        for (var element in data) {
          model.add(SubjectModel.fromJson(element));
        }
        model.reversed;
        return right(model);
      }

      return right(model);
    } catch (error) {
      final FailureModel model = FailureModel(
        error: error.toString(),
        message: "",
      );
      return Left(model);
    }
  }

  static Future<Either<FailureModel, String>> addSubject(
    SubjectModel model,
  ) async {
    try {
      final response = await FirebaseServices.instance.addData(
        CollectionKey.subjects.key,
        model.subjectId,
        model.toJson(),
      );
      if (response.status == true) {
        //* part Notifications
        await NotificationServices.subscribeToTopic(
          model.subscribeToTopicForAdmin,
        );
        return right(model.subjectName);
      } else {
        final FailureModel model = FailureModel(
          error: response.failure?.error.toString(),
          message: response.message,
        );
        return Left(model);
      }
    } catch (error) {
      final FailureModel model = FailureModel(
        error: error.toString(),
        message: 'An error occurred while creating the subject.',
      );
      return Left(model);
    }
  }

  static Future<Either<FailureModel, bool>> updateSubject(
    SubjectModel model,
  ) async {
    try {
      final response = await FirebaseServices.instance.updateData(
        CollectionKey.subjects.key,
        model.subjectId,
        model.toJson(),
      );
      if (response.status == true) {
        return right(true);
      } else {
        final FailureModel model = FailureModel(
          error: response.failure?.error.toString(),
          message: response.message,
        );
        return Left(model);
      }
    } catch (error) {
      final FailureModel model = FailureModel(
        error: error.toString(),
        message: "",
      );
      return Left(model);
    }
  }

  static Future<Either<FailureModel, bool>> removeSubject(String id) async {
    try {
      final response = await FirebaseServices.instance.removeData(
        CollectionKey.subjects.key,
        id,
      );
      if (response.status == true) {
        return right(true);
      } else {
        final FailureModel model = FailureModel(
          error: response.failure?.error.toString(),
          message: response.message,
        );
        return Left(model);
      }
    } catch (error) {
      final FailureModel model = FailureModel(
        error: error.toString(),
        message: "",
      );
      return Left(model);
    }
  }

  static Future<Either<FailureModel, SubjectModel>> joinSubject(
    String code,
    String email,
    String name,
  ) async {
    try {
      final isExists = await FirebaseServices.instance.checkIsExists(
        DataKey.subjectCodeSub.key,
        CollectionKey.subjects.key,
        code,
      );
      if (!isExists.status) {
        final FailureModel model = FailureModel(
          error: isExists.failure?.error.toString(),
          message: "Invalid subject code. Please try again.",
        );
        return Left(model);
      }
      final updateData = await FirebaseServices.instance.updateData(
        CollectionKey.subjects.key,
        isExists.data.toString(),
        {
          DataKey.subjectEmailSts.key: FieldValue.arrayUnion([email]),
        },
      );
      if (!updateData.status) {
        if (!isExists.status) {
          final FailureModel model = FailureModel(
            error: isExists.failure?.error.toString(),
            message: isExists.message,
          );
          return Left(model);
        }
      }
      final response = await FirebaseServices.instance.getData(
        isExists.data.toString(),
        CollectionKey.subjects.key,
      );
      if (response.status == true) {
        final data = SubjectModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        //* part Notifications
        await NotificationServices.subscribeToTopic(
          data.subscribeToTopicForMembers,
        );
        final length =
            data.subjectEmailSts.isEmpty ||
            data.subjectEmailSts.length - 1 == 0;
        final String and = length
            ? ""
            : "and ${data.subjectEmailSts.length} members";
        final NotificationModel model = NotificationModel(
          topicId: data.subscribeToTopicForAdmin,
          type: NotificationType.joinedSubject,
          body: "$name has joined ${data.subjectName} $and",
        );
        await NotificationServices.sendNotificationToTopic(
          id: "joined_${data.subjectId}",
          data: model.toJson(),
          stringData: model.toJsonString(),
        );
        return right(data);
      } else {
        final FailureModel model = FailureModel(
          error: response.failure?.error.toString(),
          message: response.message,
        );
        return Left(model);
      }
    } catch (error) {
      final FailureModel model = FailureModel(
        error: error.toString(),
        message: "",
      );
      return Left(model);
    }
  }
}
