import 'package:dartz/dartz.dart';

import '../../../../Core/Services/Firebase/failure_model.dart';
import '../../../../Core/Utils/Models/subject_model.dart';
import '../repositories/subject_repository.dart';

class AddSubjectUseCase {
  AddSubjectUseCase(this._repository);

  final SubjectRepository _repository;

  Future<Either<FailureModel, SubjectModel>> call(String name) {
    return _repository.addSubject(name);
  }
}

