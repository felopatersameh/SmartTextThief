import 'package:dartz/dartz.dart';

import '../../../../Core/Services/Firebase/failure_model.dart';
import '../../../../Core/Utils/Models/subject_model.dart';
import '../repositories/subject_repository.dart';

class LeaveSubjectUseCase {
  LeaveSubjectUseCase(this._repository);

  final SubjectRepository _repository;

  Future<Either<FailureModel, bool>> call(
    SubjectModel model,
    String studentEmail,
  ) {
    return _repository.leaveSubject(model, studentEmail);
  }
}

