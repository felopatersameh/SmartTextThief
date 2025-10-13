import 'package:dartz/dartz.dart';
import 'package:smart_text_thief/Core/Utils/Enums/data_key.dart';
import '../../../Core/Storage/Firebase/firebase_service.dart';
import '../../../Core/Storage/Firebase/response_model.dart';
import '../../../Core/Utils/Enums/collection_key.dart';
import '../../../Core/Utils/Models/subject_model.dart';

import '../../../Core/Storage/Firebase/failure_model.dart';

class ExamTeSources {
  static Future<Either<FailureModel, List<SubjectModel>>> getSubjects(
    String email,
    bool array,
  ) async {
    ResponseModel response;
    try {
      if (array) {
        response = await FirebaseServices.instance.findDocsInList(
          CollectionKey.subjects.key,
          email,
          nameField: DataKey.subjectEmailSts.key,
        );
      } else {
        response = await FirebaseServices.instance.findDocsByField(
          CollectionKey.subjects.key,
          email,
          nameField:
              "${DataKey.subjectTeacher.key}.${DataKey.teacherEmail.key}",
        );
      }
      
      final List<SubjectModel> model = [];
      if (response.status == true) {
        final data = response.data as List;
        for (var element in data) {
          model.add(SubjectModel.fromJson(element));
        }
        return right(model);
      }

      return right(model);
    } catch (error) {
      final FailureModel model = FailureModel(
        error: error.toString(),
        message: "",
      );
      return Left(model);
    }
  }

  static Future<Either<FailureModel, String>> addSubject(
    SubjectModel model,
  ) async {
    try {
      final response = await FirebaseServices.instance.addData(
        CollectionKey.subjects.key,
        model.subjectId,
        model.toJson(),
      );
      if (response.status == true) {
        return right(model.subjectName);
      } else {
        final FailureModel model = FailureModel(
          error: response.failure?.error.toString(),
          message: response.message,
        );
        return Left(model);
      }
    } catch (error) {
      final FailureModel model = FailureModel(
        error: error.toString(),
        message: 'An error occurred while creating the subject.',
      );
      return Left(model);
    }
  }

  static Future<Either<FailureModel, bool>> updateSubject(
    SubjectModel model,
  ) async {
    try {
      final response = await FirebaseServices.instance.updateData(
        CollectionKey.subjects.key,
        model.subjectId,
        model.toJson(),
      );
      if (response.status == true) {
        return right(true);
      } else {
        final FailureModel model = FailureModel(
          error: response.failure?.error.toString(),
          message: response.message,
        );
        return Left(model);
      }
    } catch (error) {
      final FailureModel model = FailureModel(
        error: error.toString(),
        message: "",
      );
      return Left(model);
    }
  }

  static Future<Either<FailureModel, bool>> removeSubject(String id) async {
    try {
      final response = await FirebaseServices.instance.removeData(
        CollectionKey.subjects.key,
        id,
      );
      if (response.status == true) {
        return right(true);
      } else {
        final FailureModel model = FailureModel(
          error: response.failure?.error.toString(),
          message: response.message,
        );
        return Left(model);
      }
    } catch (error) {
      final FailureModel model = FailureModel(
        error: error.toString(),
        message: "",
      );
      return Left(model);
    }
  }
}
