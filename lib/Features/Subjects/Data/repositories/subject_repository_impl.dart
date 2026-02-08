import 'package:dartz/dartz.dart';

import '../../../../Core/Services/Firebase/failure_model.dart';
import '../../../../Core/Utils/Models/exam_model.dart';
import '../../../../Core/Utils/Models/subject_model.dart';
import '../../Domain/repositories/subject_repository.dart';
import '../datasources/subjects_remote_data_source.dart';

class SubjectRepositoryImpl implements SubjectRepository {
  SubjectRepositoryImpl({
    required SubjectsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final SubjectsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<FailureModel, String>> addSubject(SubjectModel model) {
    return _remoteDataSource.addSubject(model);
  }

  @override
  Future<Either<FailureModel, bool>> deleteSubject(SubjectModel model) {
    return _remoteDataSource.deleteSubjectCompletely(model);
  }

  @override
  Future<Either<String, List<ExamModel>>> getExams(String subjectId) {
    return _remoteDataSource.getExams(subjectId);
  }

  @override
  Future<Either<FailureModel, List<SubjectModel>>> getSubjects(
    String email,
    bool isStudent,
  ) {
    return _remoteDataSource.getSubjects(email, isStudent);
  }

  @override
  Future<Either<FailureModel, SubjectModel>> joinSubject(
    String code,
    String email,
    String name,
  ) {
    return _remoteDataSource.joinSubject(code, email, name);
  }

  @override
  Future<Either<FailureModel, bool>> leaveSubject(
    SubjectModel model,
    String studentEmail,
  ) {
    return _remoteDataSource.leaveSubject(model, studentEmail);
  }

  @override
  Future<Either<FailureModel, bool>> toggleSubjectOpen(
    SubjectModel model,
    bool isOpen,
  ) {
    return _remoteDataSource.toggleSubjectOpen(model, isOpen);
  }

  @override
  Future<Either<FailureModel, bool>> updateSubject(SubjectModel model) {
    return _remoteDataSource.updateSubject(model);
  }
}
