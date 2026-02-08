import 'package:dartz/dartz.dart';

import '../../../../Core/Utils/Models/exam_model.dart';
import '../repositories/subject_repository.dart';

class GetSubjectExamsUseCase {
  GetSubjectExamsUseCase(this._repository);

  final SubjectRepository _repository;

  Future<Either<String, List<ExamModel>>> call(String subjectId) {
    return _repository.getExams(subjectId);
  }
}

