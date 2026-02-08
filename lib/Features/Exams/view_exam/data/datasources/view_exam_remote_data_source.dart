import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:smart_text_thief/Core/Services/Firebase/firebase_service.dart';
import 'package:smart_text_thief/Core/Services/Notifications/notification_model.dart';
import 'package:smart_text_thief/Core/Services/Notifications/notification_services.dart';
import 'package:smart_text_thief/Core/Utils/Enums/collection_key.dart';
import 'package:smart_text_thief/Core/Utils/Enums/data_key.dart';
import 'package:smart_text_thief/Core/Utils/Enums/notification_type.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_exam_result.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';

class ViewExamRemoteDataSource {
  Future<bool> addDefaultResult({
    required ExamModel exam,
    required ExamResultModel result,
  }) async {
    final response = await FirebaseServices.instance.updateData(
      CollectionKey.subjects.key,
      exam.examIdSubject,
      {
        DataKey.examExamResult.key: FieldValue.arrayUnion([result.toJson()]),
      },
      subCollections: [CollectionKey.exams.key],
      subIds: [exam.examId],
    );
    return response.status;
  }

  Future<Either<String, bool>> saveExam(
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
      if (!response.status) {
        return left(response.message);
      }

      final model = NotificationModel(
        topicId: examModel.examIdSubject,
        type: NotificationType.createdExam,
        body:
            'New Exam Created ${examModel.specialIdLiveExam} in $nameSubject\n${examModel.durationBeforeStarted} and ${examModel.durationAfterStarted}',
      );
      await NotificationServices.sendNotificationToTopic(
        data: model.toJson(),
        stringData: model.toJsonString(),
      );
      return right(true);
    } catch (error) {
      return left(error.toString());
    }
  }
}
