import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:smart_text_thief/Core/Services/Api/api_endpoints.dart';
import 'package:smart_text_thief/Core/Services/Api/api_service.dart';
import 'package:smart_text_thief/Features/exam/data/models/exam_model.dart';
import 'package:smart_text_thief/Features/exam/data/dto/requests/create_exam_request_model.dart';
import 'package:smart_text_thief/Features/exam/data/dto/responses/message_response_model.dart';
import 'package:smart_text_thief/Features/exam/data/models/option_model.dart';
import 'package:smart_text_thief/Features/exam/data/models/question_model.dart';
import 'package:smart_text_thief/Features/exam/data/dto/responses/student_result_response_model.dart';

class ViewExamRemoteDataSource {
  Future<Either<String, bool>> saveExam(
    ExamModel examModel,
    String subjectId,
  ) async {
    try {
      final payload = CreateExamRequestModel(
        name: examModel.name,
        levelExam: examModel.levelExam,
        isRandom: examModel.isRandom,
        questionCount: examModel.questionCount,
        timeMinutes: examModel.timeMinutes,
        startAt: examModel.startAt,
        endAt: examModel.endAt,
        questions: examModel.questions.map((question) {
          final rawOptions = question.options;
          return QuestionModel(
            id: question.id,
            text: question.text,
            type: question.type,
            correctAnswer: question.correctAnswer,
            options: rawOptions
                ?.map((item) => OptionModel(id: item.id, choice: item.choice))
                .toList(growable: false),
          );
        }).toList(growable: false),
      );

      final response = await DioHelper.postData(
        path: ApiEndpoints.subjectCreateExam(subjectId),
        data: payload.toJson(),
      );

      if (!response.status) {
        return Left(response.message);
      }

      MessageResponseModel.fromJson({
        'message': response.message,
      });
      return const Right(true);
    } catch (error) {
      return Left(error.toString());
    }
  }

  Future<Either<String, StudentResultResponseModel>> getResult({
    required String subjectId,
    required String examId,
  }) async {
    try {
      final response = await DioHelper.getData(
        path: ApiEndpoints.subjectGetResult(subjectId, examId),
      );
      if (!response.status) {
        return Left(response.message);
      }
      log("list ::: ${response.data}");

      final parsed = StudentResultResponseModel.fromJson({
        'message': response.message,
        'data': response.data,
      });
      return Right(parsed);
    } catch (error) {
      return Left(error.toString());
    }
  }
}
