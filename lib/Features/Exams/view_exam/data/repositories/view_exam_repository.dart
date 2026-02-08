import 'package:dartz/dartz.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_exam_result.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';
import 'package:smart_text_thief/Features/Exams/view_exam/data/datasources/view_exam_remote_data_source.dart';

class ViewExamRepository {
  ViewExamRepository({
    ViewExamRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? ViewExamRemoteDataSource();

  final ViewExamRemoteDataSource _remoteDataSource;

  Future<bool> addDefaultResult({
    required ExamModel exam,
    required ExamResultModel result,
  }) {
    return _remoteDataSource.addDefaultResult(exam: exam, result: result);
  }

  Future<Either<String, bool>> saveExam(
    ExamModel examModel,
    String nameSubject,
  ) {
    return _remoteDataSource.saveExam(examModel, nameSubject);
  }
}
