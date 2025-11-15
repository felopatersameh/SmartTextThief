import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../Config/setting.dart';

import '../../../../../../../Core/Utils/Enums/level_exam.dart';
import '../../../../../../../Core/Utils/Models/subject_model.dart';
import '../../../../../../Core/Services/Gemini/exam_generator_service.dart';
import '../../../../../Core/LocalStorage/get_local_storage.dart';
import '../../../../../../Core/Utils/Enums/upload_option.dart';
import '../../../../../../Core/Utils/Models/exam_model.dart';
import '../../../../../../Core/Utils/Models/exam_result_static_model.dart';
import '../../../../../../Core/Utils/generate_secure_code.dart';
import '../../../../../../Core/Utils/show_message_snack_bar.dart';
import '../../widgets/upload_option_section.dart';

part 'exam_state.dart';

class CreateExamCubit extends Cubit<CreateExamState> {
  CreateExamCubit({required SubjectModel subject})
    : super(CreateExamState(subject: subject));

  void changeLevel(LevelExam? level) {
    if (state.loadingCreating) return;
    emit(state.copyWith(selectedLevel: level));
  }

  void changeType(String value) {
    if (state.loadingCreating) return;
    emit(state.copyWith(type: value));
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
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        List<InformationFileModel> newFiles = [];

        for (var file in result.files) {
          if (file.path != null) {
            FilesType fileType;
            String extension = file.extension?.toLowerCase() ?? '';

            if (extension == 'pdf') {
              fileType = FilesType.pdf;
            } else if (['jpg', 'jpeg', 'png'].contains(extension)) {
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
            title: "${newFiles.length} file(s) uploaded successfully",
            type: MessageType.success,
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      await showMessageSnackBar(
        context,
        title: "Error picking files: $e",
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
    emit(state.copyWith(loadingCreating: true));
    final currentState = state;
    try {
      if (currentState.selectedLevel.toString().isEmpty ||
          currentState.type.trim().isEmpty) {
        await showMessageSnackBar(
          context,
          title: "All fields must be filled",
          type: MessageType.error,
        );
        throw ("All fields must be filled");
      } else if (currentState.numMultipleChoice.isEmpty &&
          currentState.numTrueFalse.isEmpty &&
          currentState.numQA.isEmpty) {
        await showMessageSnackBar(
          context,
          title: "You must select a number of questions",
          type: MessageType.error,
        );
        throw ("You must select a number of questions");
      } else if (currentState.time < 10) {
        await showMessageSnackBar(
          context,
          title: "Exam time cannot be less than 10 minutes",
          type: MessageType.warning,
        );
        throw ("Exam time cannot be less than 10 minutes");
      } else if (currentState.startDate == null ||
          currentState.endDate == null) {
        await showMessageSnackBar(
          context,
          title: "Please specify start and end time",
          type: MessageType.warning,
        );
        throw ("Please specify start and end time");
      } else if (currentState.uploadOption == UploadOption.file) {
        if (currentState.uploadedFiles.isEmpty) {
          await showMessageSnackBar(
            context,
            title: "No Files Uploaded",
            type: MessageType.error,
          );
          throw ("No Files Uploaded");
        } else {
          await created(context);
        }
      } else if (currentState.uploadOption == UploadOption.text) {
        if (currentState.uploadText.trim().isEmpty) {
          await showMessageSnackBar(
            context,
            title: "No text found",
            type: MessageType.error,
          );
          throw ("No text found");
        } else {
          await created(context);
        }
      }
    } catch (e) {
      emit(state.copyWith(loadingCreating: false));
    }
  }

  Future<void> created(BuildContext context) async {
    final numChose = state.numMultipleChoice;
    final numTF = state.numTrueFalse;
    final numQA = state.numQA;
    final sum =
        (int.tryParse(numChose) ?? 0) +
        (int.tryParse(numTF) ?? 0) +
        (int.tryParse(numQA) ?? 0);
    final response = await ExamGeneratorService().generateExamQuestions(
      level: state.selectedLevel!,
      multipleChoiceCount: numChose,
      trueFalseCount: numTF,
      shortAnswerCount: numQA,
      uploadedFiles: state.uploadedFiles,
    );
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
        examResultQA: response.questions!,
        levelExam: state.selectedLevel!,
        numberOfQuestions: sum,
        time: state.time.toString(),
        typeExam: state.type,
        randomQuestions: state.canOpenQuestions,
      ),
    );
    if (!context.mounted) return;
    if (!response.isSuccess) throw ("error");
    await showMessageSnackBar(
      context,
      title: "Created is Done",
      type: MessageType.success,
    );
    emit(state.copyWith(loadingCreating: false));
    if (!context.mounted) return;
    AppRouter.nextScreenNoPath(
      context,
      NameRoutes.view,
      extra: {
        "exam": exam,
        "isEditMode": true,
        "nameSubject": state.subject.subjectName,
      },
      pathParameters: {"exam": exam.examId, "id": exam.examIdSubject},
    );
  }
}
