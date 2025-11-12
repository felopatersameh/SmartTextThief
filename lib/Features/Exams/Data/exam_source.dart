import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:smart_text_thief/Core/Utils/Enums/notification_type.dart';
import '../../../Core/Services/Firebase/firebase_service.dart';
import '../../../Core/Services/Notifications/notification_services.dart';
import '../../../Core/Utils/Enums/collection_key.dart';
import '../../../Core/Utils/Enums/data_key.dart';
import '../../../Core/Utils/Models/exam_result_q_a.dart';

import '../../../Core/Utils/Models/exam_model.dart';
import '../../../Core/Utils/Models/notification_model.dart';

class ExamSource {
  static Future<Either<String, bool>> createExam(
    ExamModel examModel,
    String nameSubject,
  ) async {
    try {
      final response = await FirebaseServices.instance.addData(
        CollectionKey.subjects.key,
        examModel.examIdSubject,
        examModel.toJson(),
        subCollections: [CollectionKey.exams.key],
        subIds: [examModel.examId],
      );
      if (response.status) {
        final NotificationModel model = NotificationModel(
          topicId: examModel.examId,
          type: NotificationType.createdExam,
          body:
              "New Exam Created ${examModel.specialIdLiveExam} in $nameSubject",
        );
        NotificationServices.sendNotificationToTopic(
          topic: examModel.examIdSubject,
          data: model.toJson(),
          stringData: model.toJsonString()
        );
        return right(response.status);
      } else {
        return left(response.message);
      }
    } catch (e) {
      return left(e.toString());
    }
  }

  static Future<Either<String, bool>> removeExam(
    String idSuject,
    String idExam,
  ) async {
    try {
      final response = await FirebaseServices.instance.removeData(
        CollectionKey.subjects.key,
        idSuject,
        subCollections: [CollectionKey.exams.key],
        subIds: [idExam],
      );
      if (response.status) {
        return right(response.status);
      } else {
        return left(response.message);
      }
    } catch (e) {
      return left(e.toString());
    }
  }

  static Future<Either<String, bool>> updateTimeExam(
    String idSubject,
    String idExam,
    DateTime time,
    DataKey key,
  ) async {
    try {
      final response = await FirebaseServices.instance.updateData(
        CollectionKey.subjects.key,
        idSubject,
        subCollections: [CollectionKey.exams.key],
        subIds: [idExam],
        {key.key: time.millisecondsSinceEpoch},
      );
      if (response.status) {
        return right(response.status);
      } else {
        return left(response.message);
      }
    } catch (e) {
      return left(e.toString());
    }
  }

  static Future<Either<String, bool>> updateAnwserQuestionInExam(
    String idSubject,
    String idExam,
    ExamResultQA examResultQA,
  ) async {
    try {
      final response = await FirebaseServices.instance.updateData(
        CollectionKey.subjects.key,
        idSubject,
        {
          "exam_Q&A": FieldValue.arrayUnion([examResultQA]),
        },
        subCollections: [CollectionKey.exams.key],
        subIds: [idExam],
      );
      if (response.status) {
        return right(response.status);
      } else {
        return left(response.message);
      }
    } catch (e) {
      return left(e.toString());
    }
  }

  static Future<Either<String, bool>> removeAnwserQuestionInExam(
    String idSubject,
    String idExam,
    ExamResultQA examResultQA,
  ) async {
    try {
      final response = await FirebaseServices.instance.updateData(
        CollectionKey.subjects.key,
        idSubject,
        {
          "exam_Q&A": FieldValue.arrayRemove([examResultQA]),
        },
        subCollections: [CollectionKey.exams.key],
        subIds: [idExam],
      );
      if (response.status) {
        return right(response.status);
      } else {
        return left(response.message);
      }
    } catch (e) {
      return left(e.toString());
    }
  }
}
