import 'package:dartz/dartz.dart';

import '../../../../Core/Services/Firebase/failure_model.dart';
import '../../../../Core/Utils/Models/subject_model.dart';
import '../repositories/subject_repository.dart';

class GetSubjectsUseCase {
  GetSubjectsUseCase(this._repository);

  final SubjectRepository _repository;

  Future<Either<FailureModel, List<SubjectModel>>> call()
  {
    return _repository.getSubjects();
  }
}

