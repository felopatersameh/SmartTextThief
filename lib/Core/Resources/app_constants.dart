
class AppConstants {
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 300);

  static const Duration doExamBackgroundGraceDuration =
      Duration(minutes: 2);

  static const int minExamDurationMinutes = 10;
  static const int maxDatePickerYearsAhead = 2;
  static const int examIdPreviewLength = 4;
  static const int examLabelMaxLength = 8;

  static const String liveExamCollection = 'Exam_Live';
  static const String liveExamStartTimeKey = 'start_time';
  static const String liveExamTimeKey = 'time';
  static const String liveExamDisposeKey = 'dispose_exam';
  static const String multipleChoiceType = 'multiple_choice';
  static const String shortAnswerType = 'short_answer';
  static const String submittedExamNotificationPrefix = 'doExam_';
  static const String adminTopicSuffix = '_admin';
  static const String subjectClosedErrorCode = 'subject_closed';
  static const String joinedSubjectNotificationPrefix = 'joined_';
  static const String allUsersTopic = 'allUsers';

  static const String fileExtensionPdf = 'pdf';
  static const String fileExtensionJpg = 'jpg';
  static const String fileExtensionJpeg = 'jpeg';
  static const String fileExtensionPng = 'png';
  static const List<String> supportedExamFileExtensions = [
    fileExtensionPdf,
    fileExtensionJpg,
    fileExtensionJpeg,
    fileExtensionPng,
  ];
  static const List<String> imageFileExtensions = [
    fileExtensionJpg,
    fileExtensionJpeg,
    fileExtensionPng,
  ];

  static const String sizeUnitBytes = 'B';
  static const String sizeUnitKilobytes = 'KB';
  static const String sizeUnitMegabytes = 'MB';

  static const String routeKeyId = 'id';
  static const String routeKeyExam = 'exam';
  static const String routeKeyEmail = 'email';
  static const String routeKeyNameSubject = 'nameSubject';
  static const String routeKeyIsEditMode = 'isEditMode';
  static const String routeKeySubject = 'subject';
  static const String routeKeyExams = 'exams';
  static const String routeKeyResults = 'results';

  static const String appLogoAsset = 'assets/Image/s2.png';
}
