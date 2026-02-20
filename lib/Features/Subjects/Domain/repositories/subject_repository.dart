import 'package:dartz/dartz.dart';

import '../../../../Core/Services/Firebase/failure_model.dart';
import '../../../../Core/Utils/Models/exam_model.dart';
import '../../../../Core/Utils/Models/subject_model.dart';

abstract class SubjectRepository {
  Future<Either<String, List<ExamModel>>> getExams(String subjectId);

  Future<Either<FailureModel, List<SubjectModel>>> getSubjects();

  Future<Either<FailureModel, SubjectModel>> addSubject(String model);

  Future<Either<FailureModel, SubjectModel>> joinSubject(
    String code,
    String email,
    String name,
  );

  Future<Either<FailureModel, bool>> updateSubject(SubjectModel model);

  Future<Either<FailureModel, bool>> deleteSubject(SubjectModel model);

  Future<Either<FailureModel, bool>> toggleSubjectOpen(
    SubjectModel model,
    bool isOpen,
  );

  Future<Either<FailureModel, bool>> leaveSubject(
    SubjectModel model,
    String studentEmail,
  );
}
