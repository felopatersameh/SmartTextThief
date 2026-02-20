import 'package:dartz/dartz.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Services/Api/api_endpoints.dart';
import 'package:smart_text_thief/Core/Services/Api/api_service.dart';
import 'package:smart_text_thief/Core/Services/Notifications/notification_model.dart';
import 'package:smart_text_thief/Core/Services/Notifications/notification_services.dart';
import 'package:smart_text_thief/Core/Utils/Enums/notification_type.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_exam_result.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';

class ViewExamRemoteDataSource {
  Future<bool> addDefaultResult({
    required ExamModel exam,
    required ExamResultModel result,
  }) async {
    return true;
  }

  Future<Either<String, bool>> saveExam(
    ExamModel examModel,
    String nameSubject,
  ) async {
    try {
      final payload = {
        'name': examModel.examStatic.typeExam,
        'levelExam': examModel.examStatic.levelExam.name,
        'isRandom': examModel.examStatic.randomQuestions,
        'questionCount': examModel.examStatic.numberOfQuestions,
        'timeMinutes': int.tryParse(examModel.examStatic.time) ?? 0,
        'startAt': examModel.startedAt.toIso8601String(),
        'endAt': examModel.examFinishAt.toIso8601String(),
        'questions': [
          for (final question in examModel.examStatic.examResultQA)
            {
              'id': question.questionId,
              'text': question.questionText,
              'type': question.questionType,
              'correctAnswer': question.correctAnswer,
              'options': [
                for (int i = 0; i < question.options.length; i++)
                  {
                    'id': '${i + 1}',
                    'choice': question.options[i],
                  },
              ],
            },
        ],
      };

      final response = await DioHelper.postData(
        path: ApiEndpoints.subjectCreateExam(examModel.examIdSubject),
        data: payload,
      );

      final ok = response.status;
      if (!ok) {
        final body = _toMap(response.data);
        return Left(body['message']?.toString() ?? 'Failed to save exam');
      }

      final model = NotificationModel(
        topicId: examModel.examIdSubject,
        type: NotificationType.createdExam,
        body: DataSourceStrings.examCreatedBody(
          examModel.specialIdLiveExam,
          nameSubject,
          examModel.durationBeforeStarted,
          examModel.durationAfterStarted,
        ),
      );
      await NotificationServices.sendNotificationToTopic(
        data: model.toJson(),
        stringData: model.toJsonString(),
      );
      return const Right(true);
    } catch (error) {
      return Left(error.toString());
    }
  }

  Map<String, dynamic> _toMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }
}
