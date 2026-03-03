import 'package:dartz/dartz.dart';
import 'package:smart_text_thief/Features/exam/data/models/analytics_model.dart';

import '../repositories/subject_repository.dart';

class GetAnalyticsSubjectsUseCase {
  GetAnalyticsSubjectsUseCase(this._repository);

  final SubjectRepository _repository;

  Future<Either<String, AnalyticsSubjectModel>> call(String subjectId) {
    return _repository.getAnalyticsSubjects(subjectId);
  }
}


