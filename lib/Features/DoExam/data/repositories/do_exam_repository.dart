import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/Enums/result_exam_status.dart';
import 'package:smart_text_thief/Features/DoExam/data/datasources/do_exam_remote_data_source.dart';

class DoExamRepository {
  DoExamRepository({
    DoExamRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? DoExamRemoteDataSource();

  final DoExamRemoteDataSource _remoteDataSource;

  Future<void> createLiveExam(ExamModel model) {
    return _remoteDataSource.createLiveExam(model);
  }

  String listenLiveExam(
    ExamModel model,
    void Function(dynamic data, String? key) onData, {
    void Function(dynamic error)? onError,
  }) {
    return _remoteDataSource.listenLiveExam(
      model,
      onData,
      onError: onError,
    );
  }

  Future<void> unListenLiveExam(String listenerId) {
    return _remoteDataSource.unListenLiveExam(listenerId);
  }

  Future<void> updateLiveExamTimer(ExamModel model, int timerExam) {
    return _remoteDataSource.updateLiveExamTimer(model, timerExam);
  }

  Future<void> updateAnswer({
    required ExamModel model,
    required String questionId,
    required String answer,
  }) {
    return _remoteDataSource.updateAnswer(
      model: model,
      questionId: questionId,
      answer: answer,
    );
  }

  Future<bool> hasStudentSubmitted(ExamModel model) {
    return _remoteDataSource.hasStudentSubmitted(model);
  }

  Future<bool> submitExam({
    required ExamModel model,
    required Map<String, String> userAnswers,
    required ResultExamStatus status,
    required List<ResultExamStatus> statusHistory,
    String? source,
  }) {
    return _remoteDataSource.submitExam(
      model: model,
      userAnswers: userAnswers,
      status: status,
      statusHistory: statusHistory,
      source: source,
    );
  }

  Future<void> deleteLiveExam(ExamModel model) {
    return _remoteDataSource.deleteLiveExam(model);
  }

}
