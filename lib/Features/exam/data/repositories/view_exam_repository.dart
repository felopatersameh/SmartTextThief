import 'package:dartz/dartz.dart';
import 'package:smart_text_thief/Features/exam/data/models/exam_model.dart';
import 'package:smart_text_thief/Features/exam/data/dto/responses/student_result_response_model.dart';
import 'package:smart_text_thief/Features/exam/data/datasource/view_exam_remote_data_source.dart';

class ViewExamRepository {
  ViewExamRepository({
    ViewExamRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? ViewExamRemoteDataSource();

  final ViewExamRemoteDataSource _remoteDataSource;

  Future<Either<String, bool>> saveExam(
    ExamModel examModel,
    String idSubject,
  ) {
    return _remoteDataSource.saveExam(examModel, idSubject);
  }

  Future<Either<String, StudentResultResponseModel>> getResult({
    required String idSubject,
    required String idExam,
  }) {
    return _remoteDataSource.getResult(
      subjectId: idSubject,
      examId: idExam,
    );
  }
}

