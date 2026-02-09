import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Config/setting.dart';
import 'package:smart_text_thief/Config/Routes/route_data.dart';
import 'package:smart_text_thief/Core/LocalStorage/get_local_storage.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Utils/Enums/level_exam.dart';
import 'package:smart_text_thief/Core/Utils/Enums/upload_option.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_result_static_model.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_model.dart';
import 'package:smart_text_thief/Core/Utils/generate_secure_code.dart';
import 'package:smart_text_thief/Core/Utils/show_message_snack_bar.dart';
import 'package:smart_text_thief/Features/Exams/create_exam/data/models/information_file_model.dart';
import 'package:smart_text_thief/Features/Exams/create_exam/data/repositories/create_exam_repository.dart';
import 'package:smart_text_thief/Features/Profile/Persentation/cubit/profile_cubit.dart';

part 'create_exam_state.dart';

class CreateExamCubit extends Cubit<CreateExamState> {
  CreateExamCubit({
    required SubjectModel subject,
    CreateExamRepository? repository,
  })  : _repository = repository ?? CreateExamRepository(),
        super(CreateExamState(subject: subject));

  final CreateExamRepository _repository;

  void changeLevel(LevelExam? level) {
    if (state.loadingCreating) return;
    emit(state.copyWith(selectedLevel: level));
  }

  void changeName(String value) {
    if (state.loadingCreating) return;
    emit(state.copyWith(name: value));
  }

  void changeContent(String value) {
    if (state.loadingCreating) return;
    emit(state.copyWith(content: value));
  }

  void toggleCanOpenQuestions(bool value) {
    if (state.loadingCreating) return;
    emit(state.copyWith(canOpenQuestions: value));
  }

  void changeQuestionNumbers({String? multiple, String? tf, String? qa}) {
    if (state.loadingCreating) return;
    emit(
      state.copyWith(
        numMultipleChoice: multiple ?? state.numMultipleChoice,
        numTrueFalse: tf ?? state.numTrueFalse,
        numQA: qa ?? state.numQA,
      ),
    );
  }

  void changeTime(int time) {
    if (state.loadingCreating) return;

    emit(state.copyWith(time: time));
  }

  void changeStartDate(DateTime date) {
    emit(state.copyWith(startDate: date));
  }

  void changeEndDate(DateTime date) {
    emit(state.copyWith(endDate: date));
  }

  void changeUploadOption(UploadOption option) {
    if (state.loadingCreating) return;
    emit(state.copyWith(uploadOption: option));
  }

  Future<void> pickFiles(BuildContext context) async {
    if (state.loadingCreating) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: AppConstants.supportedExamFileExtensions,
      );

      if (result != null && result.files.isNotEmpty) {
        List<InformationFileModel> newFiles = [];

        for (var file in result.files) {
          if (file.path != null) {
            FilesType fileType;
            String extension = file.extension?.toLowerCase() ?? '';

            if (extension == AppConstants.fileExtensionPdf) {
              fileType = FilesType.pdf;
            } else if (AppConstants.imageFileExtensions.contains(extension)) {
              fileType = FilesType.image;
            } else {
              continue;
            }

            newFiles.add(
              InformationFileModel(
                name: file.name,
                path: file.path!,
                type: fileType,
                size: file.size,
              ),
            );
          }
        }

        if (newFiles.isNotEmpty) {
          List<InformationFileModel> allFiles = [
            ...state.uploadedFiles,
            ...newFiles,
          ];
          emit(state.copyWith(uploadedFiles: allFiles));
          if (!context.mounted) return;
          await showMessageSnackBar(
            context,
            title: CreateExamStrings.uploadFilesSuccess(newFiles.length),
            type: MessageType.success,
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      await showMessageSnackBar(
        context,
        title: CreateExamStrings.errorPickingFiles('$e'),
        type: MessageType.error,
      );
    }
  }

  void removeFile(int index) {
    if (state.loadingCreating) return;

    List<InformationFileModel> files = List.from(state.uploadedFiles);
    if (index >= 0 && index < files.length) {
      files.removeAt(index);
      emit(state.copyWith(uploadedFiles: files));
    }
  }

  void clearAllFiles() {
    if (state.loadingCreating) return;
    emit(state.copyWith(uploadedFiles: []));
  }

  void changeTextUpload(String text) {
    if (state.loadingCreating) return;
    emit(state.copyWith(uploadText: text));
  }

  Future<void> submitExam(BuildContext context) async {
    if (state.loadingCreating) return;
    emit(state.copyWith(loadingCreating: true));
    final currentState = state;
    if (currentState.selectedLevel == null ||
        currentState.name.trim().isEmpty) {
      await showMessageSnackBar(
        context,
        title: CreateExamStrings.allFieldsRequired,
        type: MessageType.error,
      );
      emit(state.copyWith(loadingCreating: false));
      return;
    }

    final totalQuestions = (int.tryParse(currentState.numMultipleChoice) ?? 0) +
        (int.tryParse(currentState.numTrueFalse) ?? 0) +
        (int.tryParse(currentState.numQA) ?? 0);
    if (totalQuestions <= 0) {
      await showMessageSnackBar(
        context,
        title: CreateExamStrings.selectQuestionCount,
        type: MessageType.error,
      );
      emit(state.copyWith(loadingCreating: false));
      return;
    }

    if (currentState.time < AppConstants.minExamDurationMinutes) {
      await showMessageSnackBar(
        context,
        title: CreateExamStrings.minExamTime,
        type: MessageType.warning,
      );
      emit(state.copyWith(loadingCreating: false));
      return;
    }

    if (currentState.startDate == null || currentState.endDate == null) {
      await showMessageSnackBar(
        context,
        title: CreateExamStrings.specifyStartEnd,
        type: MessageType.warning,
      );
      emit(state.copyWith(loadingCreating: false));
      return;
    }

    if (!currentState.endDate!.isAfter(currentState.startDate!)) {
      await showMessageSnackBar(
        context,
        title: CreateExamStrings.endAfterStart,
        type: MessageType.warning,
      );
      emit(state.copyWith(loadingCreating: false));
      return;
    }

    if (currentState.uploadOption == UploadOption.file &&
        currentState.uploadedFiles.isEmpty) {
      await showMessageSnackBar(
        context,
        title: CreateExamStrings.noFilesUploaded,
        type: MessageType.error,
      );
      emit(state.copyWith(loadingCreating: false));
      return;
    }

    if (currentState.uploadOption == UploadOption.text &&
        currentState.uploadText.trim().isEmpty) {
      await showMessageSnackBar(
        context,
        title: CreateExamStrings.noTextFound,
        type: MessageType.error,
      );
      emit(state.copyWith(loadingCreating: false));
      return;
    }

    try {
      await created(context);
    } finally {
      emit(state.copyWith(loadingCreating: false));
    }
  }

  Future<void> created(BuildContext context) async {
    final numChose = state.numMultipleChoice;
    final numTF = state.numTrueFalse;
    final numQA = state.numQA;
    final sum = (int.tryParse(numChose) ?? 0) +
        (int.tryParse(numTF) ?? 0) +
        (int.tryParse(numQA) ?? 0);
    final profileApiKey =
        context.read<ProfileCubit>().state.model?.userGeminiApiKey.trim() ?? "";
    final userApiKey = profileApiKey.isNotEmpty
        ? profileApiKey
        : EnvConfig.geminiFallbackApiKey;
    if (userApiKey.isEmpty) {
      await showMessageSnackBar(
        context,
        title: CreateExamStrings.addGeminiKeyFirst,
        type: MessageType.warning,
      );
      return;
    }

    final response = await _repository.generateExamQuestions(
      apiKey: userApiKey,
      level: state.selectedLevel!,
      multipleChoiceCount: numChose,
      trueFalseCount: numTF,
      shortAnswerCount: numQA,
      uploadedFiles: state.uploadedFiles,
      examDurationMinutes: state.time,
      contentContext: state.content,
      manualText: state.uploadText,
    );
    if (!context.mounted) return;
    final questions = response.questions;
    if (!response.isSuccess || questions == null || questions.isEmpty) {
      final errorMessage = response.errorMessage ?? "";
      await showMessageSnackBar(
        context,
        title: errorMessage.isNotEmpty
            ? errorMessage
            : CreateExamStrings.generationFailed,
        type: MessageType.error,
      );
      return;
    }

    final userId = GetLocalStorage.getIdUser();
    final exam = ExamModel(
      examId: generateExamId(),
      examIdSubject: state.subject.subjectId,
      examIdTeacher: userId,
      startedAt: state.startDate!,
      examFinishAt: state.endDate!,
      examCreatedAt: DateTime.now(),
      examResult: [],
      examStatic: ExamStaticModel(
        examResultQA: questions,
        levelExam: state.selectedLevel!,
        numberOfQuestions: sum,
        time: state.time.toString(),
        typeExam: state.name,
        randomQuestions: state.canOpenQuestions,
      ),
    );

    await showMessageSnackBar(
      context,
      title: CreateExamStrings.createdDone,
      type: MessageType.success,
    );
    if (!context.mounted) return;
    AppRouter.pushToViewExam(
      context,
      data: ViewExamRouteData(
        exam: exam,
        isEditMode: true,
        nameSubject: state.subject.subjectName,
      ),
    );
  }
}
