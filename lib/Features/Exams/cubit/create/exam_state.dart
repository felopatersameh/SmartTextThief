part of 'exam_cubit.dart';

class CreateExamState extends Equatable {
  final SubjectModel subject;
  final LevelExam? selectedLevel;
  final String type;
  final bool canOpenQuestions;
  final String numMultipleChoice;
  final String numTrueFalse;
  final String numQA;
  final int time; // added time int
  final UploadOption uploadOption;
  final List<InformationFileModel> uploadedFiles;
  final String uploadText;
  final bool loadingCreating;
  final DateTime? startDate;
  final DateTime? endDate;

  const CreateExamState({
    required this.subject,
    this.selectedLevel,
    this.type = '',
    this.canOpenQuestions = false,
    this.numMultipleChoice = '',
    this.numTrueFalse = '',
    this.numQA = '',
    this.time = 0, // added time int default
    this.uploadOption = UploadOption.file,
    this.uploadedFiles = const [],
    this.uploadText = '',
    this.loadingCreating = false,
    this.startDate,
    this.endDate,
  });

  CreateExamState copyWith({
    SubjectModel? subject,
    LevelExam? selectedLevel,
    String? type,
    bool? canOpenQuestions,
    String? numMultipleChoice,
    String? numTrueFalse,
    String? numQA,
    int? time, // added time int param
    UploadOption? uploadOption,
    List<InformationFileModel>? uploadedFiles,
    String? uploadText,
    bool? loadingCreating,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return CreateExamState(
      subject: subject ?? this.subject,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      type: type ?? this.type,
      canOpenQuestions: canOpenQuestions ?? this.canOpenQuestions,
      numMultipleChoice: numMultipleChoice ?? this.numMultipleChoice,
      numTrueFalse: numTrueFalse ?? this.numTrueFalse,
      numQA: numQA ?? this.numQA,
      time: time ?? this.time, // added time copy
      uploadOption: uploadOption ?? this.uploadOption,
      uploadedFiles: uploadedFiles ?? this.uploadedFiles,
      uploadText: uploadText ?? this.uploadText,
      loadingCreating: loadingCreating ?? this.loadingCreating,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
    subject,
    selectedLevel,
    type,
    canOpenQuestions,
    numMultipleChoice,
    numTrueFalse,
    numQA,
    time, // added time int to props
    uploadOption,
    uploadedFiles,
    uploadText,
    loadingCreating,
    startDate,
    endDate,
  ];
}
