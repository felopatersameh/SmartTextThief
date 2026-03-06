import 'package:smart_text_thief/Features/Exams/shared/Enums/level_exam.dart';
import '../../Data/DTO/Responses/exam_generation_result_model.dart';
import '../../Data/sources/create_exam_remote_data_source.dart';
import '../../shared/Models/information_file_model.dart';

class CreateExamRepository {
  CreateExamRepository({
    CreateExamRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? CreateExamRemoteDataSource();

  final CreateExamRemoteDataSource _remoteDataSource;

  Future<ExamGenerationResultModel> generateExamQuestions({
    required String apiKey,
    required String modelName,
    required LevelExam level,
    required String multipleChoiceCount,
    required String trueFalseCount,
    required String shortAnswerCount,
    required List<InformationFileModel> uploadedFiles,
    required int examDurationMinutes,
    required String contentContext,
    required String manualText,
  }) {
    return _remoteDataSource.generateExamQuestions(
      apiKey: apiKey,
      modelName: modelName,
      level: level,
      multipleChoiceCount: multipleChoiceCount,
      trueFalseCount: trueFalseCount,
      shortAnswerCount: shortAnswerCount,
      uploadedFiles: uploadedFiles,
      examDurationMinutes: examDurationMinutes,
      contentContext: contentContext,
      manualText: manualText,
    );
  }
}

