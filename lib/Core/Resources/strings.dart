class AppStrings {
  //* Authentication
  static const String welcome = 'Welcome to Future Choices';
  static const String welcomeHint = 'Join us to experience selection';
  static const String login = 'Login';
  static const String email = 'Email ';
  static const String name = 'Full Name';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password ? ';
  static const String orSignInWithGoogle = 'Sign in with Google';
  static const String orSignInWithFacebook = 'Sign in with Facebook';
  static const String orContinue = 'Or continue with';
  static const String donthaveAccount = "Don't have an account?";
  static const String signUp = 'Sign Up';
  static const String google = 'Google';
  static const String createYourAccount = 'Create your account';
  static const String alreadyHaveAccount = 'Already have an account?';

  //* Main
  static const String home = 'Home';
  static const String search = 'Search';
  static const String profile = 'Profile';
  static const String calender = 'Calender';
  static const String chat = 'Chat';
  static const String addProject = 'Add Project';
  static const String notification = 'Notification';

  //* Home
  static const String completedTasks = 'Completed Tasks';
  static const String completed = 'Completed';
  static const String ongoingTasks = 'Ongoing Tasks';
  static const String seeAll = 'See All';
  static const String teamMembers = 'Team members';
  static const String dueOn = 'Due on :';

  //* Tasks
  static const String viewTask = 'View Task';
  static const String projectDetails = 'Project Details';
  static const String tasks = 'All Tasks ';
  static const String addTasks = 'Add Task';

  //* Common
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String save = 'Save';
  static const String ok = 'OK';
  static const String loading = 'Loading...';
}

class LoginStrings {
  static const String loadingGoogleSignIn = 'loading Sign in with Google';

  static const String onboardingCreateExamsTitle = 'Create Exams Faster';
  static const String onboardingCreateExamsDesc =
      'Generate complete exams in minutes using AI with clean structure and ready-to-use questions.';

  static const String onboardingManageSubjectsTitle = 'Manage Subjects Easily';
  static const String onboardingManageSubjectsDesc =
      'Organize subjects, share codes with students, and keep all your exam workflow in one place.';

  static const String onboardingTrackResultsTitle = 'Track Student Results';
  static const String onboardingTrackResultsDesc =
      'View submissions, monitor performance, and improve learning outcomes with clear data.';
}

class RoleStrings {
  static const String chooseYourRole = 'Choose your role';
  static const String selectYourRole = 'Select your role';
  static const String chooseHowToUse =
      'Choose how you want to use the app first.';
  static const String iAmTeacher = 'I am a Teacher';
  static const String iAmStudent = 'I am a Student';
  static const String failedToSaveRole = 'Failed to save role, please try again';
}

class MainStrings {
  static const String subjectTab = 'Subject';
  static const String notificationsTab = 'Notifications';
  static const String profileTab = 'Profile';
}

class NotificationStrings {
  static const String noNotificationsYet = 'No notifications yet';
  static const String noNotificationsHint =
      "We'll let you know when something new happens.";
}

class SubjectStrings {
  static const String subjectAddedSuccessfully = 'Subject added successfully!';
  static const String subjectJoinedSuccessfully = 'Joined subject successfully!';

  static const String addNewSubject = 'Add New Subject';
  static const String addSubject = 'Add Subject';
  static const String joinSubject = 'Join Subject';
  static const String join = 'Join';
  static const String joining = 'Joining....';
  static const String creatingSubject = 'Creating subject...';
  static const String leave = 'Leave';
  static const String code = 'Code';
  static const String enterCode = 'Enter Code';
  static const String pleaseEnterSubjectName = 'Please enter subject name';
  static const String pleaseEnterCode = 'Please enter code';
  static const String createdOn = 'Created on';

  static const String instructor = 'Instructor';
  static const String email = 'Email';
  static const String students = 'Students';
  static const String exams = 'Exams';
  static const String created = 'Created';
  static const String subjectCode = 'Subject Code';
  static const String codeCopied = 'Code copied';

  static const String openForJoining = 'Open for joining';
  static const String closedForJoining = 'Closed for joining';
  static const String closeSubject = 'Close Subject';
  static const String openSubject = 'Open Subject';
  static const String deleteSubject = 'Delete Subject';
  static const String leaveSubject = 'Leave Subject';
  static const String subjectDashboard = 'Subject Dashboard';

  static const String searchSubjectsHint = 'Search subjects...';
  static const String noSubjectsFound = 'No subjects found';
  static const String tryAdjustingSearch = 'Try adjusting your search';
  static const String noSubjectsAvailable = 'No subjects available currently';
  static const String noSubjectsAvailableHint =
      'When new subjects are added, they will appear here.';
  static const String noExamsAvailable = 'No exams available currently';
  static const String noExamsAvailableHint = 'Check back later for new exams.';

  static const String deleteSubjectMessage =
      'This will permanently delete the subject and all related exams.';
  static const String leaveSubjectMessage =
      'You will lose access to this subject. Continue?';
  static const String openSubjectMessage =
      'Students will be able to join this subject again.';
  static const String closeSubjectMessage =
      'No new student will be able to join this subject.';
}

class ExamCardStrings {
  static const String ended = 'Ended';
  static const String live = 'Live';
  static const String upcoming = 'Upcoming';
  static const String start = 'Start';
  static const String end = 'End';
  static const String attempts = 'Attempts';
  static const String questions = 'Questions';
  static const String viewResults = 'View Results';
  static const String pdf = 'PDF';
  static const String waitingForResults = 'Waiting for results...';
  static const String startExamNow = 'Start Exam Now';
  static const String showMyResults = 'Show My Results';

  static String examStartsIn(String duration) => 'Exam starts in $duration';
  static String timeLeft(String duration) => 'Time left: $duration';
  static String timeRemaining(String duration) => 'Time remaining: $duration';
}

class DashboardStrings {
  static const String noSubjectSelected = 'No subject selected';
  static const String teacherOnlyMessage =
      'Dashboard is available for teachers only.';
  static const String noStudentRecordsYet = 'No student records yet';
  static const String studentsScoresDetails = 'Students scores details';

  static const String overview = 'Overview';
  static const String overviewSubtitle = 'Quick metrics for this subject';
  static const String examsCount = 'Exams Count';
  static const String studentsCount = 'Students Count';
  static const String averageScore = 'Average Score';
  static const String passRate = 'Pass Rate';

  static const String examDifficulty = 'Exam Difficulty';
  static const String examDifficultySubtitle = 'Distribution by level';
  static const String examDifficultyChartSubtitle = 'Easy vs normal vs hard';
  static const String noExamsToAnalyze = 'No exams yet to analyze.';

  static const String questionPerformance = 'Question Performance';
  static const String questionPerformanceSubtitle = 'Tap a bar for more details';
  static const String questionPerformanceLegend = 'Green = correct, Red = wrong';
  static const String noAnsweredQuestions = 'No answered questions available yet.';

  static const String topicAnalysis = 'Topic / Lesson Analysis';
  static const String topicAnalysisSubtitle = 'Weak lessons are highlighted';
  static const String topicAnalysisChartSubtitle =
      'Each bar represents one lesson';
  static const String noTopicPerformance = 'No topic performance available yet.';
  static const String reviewThisLesson = 'Review this lesson';

  static const String timeAnalysis = 'Time Analysis';
  static const String timeAnalysisSubtitle = 'Average exam time trend';
  static const String timeAnalysisChartSubtitle =
      'Average solving time across exams';
  static const String noTimeData = 'No time data available yet.';
  static const String longest = 'Longest';

  static const String studentPerformanceSplit = 'Student Performance Split';
  static const String studentPerformanceSplitSubtitle =
      'Privacy-friendly distribution';
  static const String studentPerformanceSplitChartSubtitle =
      'No names, percentages only';
  static const String noStudentResults = 'No student results yet.';
  static const String excellent = 'Excellent';
  static const String average = 'Average';
  static const String needsSupport = 'Needs Support';

  static const String examComparison = 'Exam Comparison';
  static const String examComparisonSubtitle = 'Progress across exams';
  static const String examComparisonTrendSubtitle = 'Trend for average scores';
  static const String noComparisonData =
      'Not enough exam results for comparison yet.';
  static const String improving = 'Performance is improving';
  static const String needsAttention = 'Performance needs attention';

  static const String successRate = 'Success Rate';
  static const String mostSelected = 'Most Selected';
  static const String attemptsLabel = 'Attempts';
  static const String studentsScoreMatrix = 'Students Score Matrix';
  static const String studentsScoreMatrixHint =
      'Each student total score + red box for exams not attempted or score 0';
  static const String noStudentData = 'No student data available yet.';

  static const String noData = 'No data';
  static const String noChartData = 'No chart data';
  static const String noStudentSplitData = 'No student split data';
  static const String noClearAnswer = 'No clear answer';
  static const String latestExam = 'Latest exam';
  static const String noMissingOrZeroScores = 'No missing or zero-score exams.';
  static const String point = 'Point';
  static const String correct = 'Correct';
  static const String wrong = 'Wrong';
  static const String easy = 'Easy';
  static const String normal = 'Normal';
  static const String hard = 'Hard';
  static const String noAnswer = 'no answer';
  static const String total = 'Total';
  static const String minuteSuffix = 'm';

  static String examsChip(int count) => '$count exams';
  static String studentsChip(int count) => '$count students';
  static String createdChip(String createdAt) => 'Created $createdAt';
  static String studentsScoreButton(int count) => '$studentsScoresDetails ($count)';
  static String latestDifficulty(String value) => '$latestExam: $value';
  static String latestDifficultyEmpty() => '$latestExam: -';
  static String questionLabel(int index) => 'Q${index + 1}';
  static String topicLabel(int index) => 'T${index + 1}';
  static String examLabel(int index) => 'Exam ${index + 1}';
  static String examFallbackLabel(int fallbackIndex) => 'Exam $fallbackIndex';
  static String examIdLabel(String idPart) => 'Exam $idPart';
  static String insightTitle(String examName, String label) => '$examName - $label';
  static String longestValue(String fullLabel, String minutes) =>
      '$longest: $fullLabel ($minutes min)';
  static String trendMessage(bool improving) =>
      improving ? 'Performance is improving' : 'Performance needs attention';
  static String totalLabel(String totalValue) => '$total $totalValue';
  static String flaggedExamLabel(String examName) => '- $examName';
  static String matrixHintText(String title, String value) => '$title: $value';
  static String chartValueWithSuffix(String label, String value) => '$label\n$value';
}

class ProfileStrings {
  static const String manageAccount = 'Manage Account';
  static const String geminiApiKey = 'Gemini API Key';
  static const String about = 'About';
  static const String help = 'Help';
  static const String logout = 'logOut';
  static const String deleteAccount = 'Delete Account';
  static const String waiting = 'Waiting...';
  static const String deletingAccount = 'Deleting account...';
  static const String failedToDeleteAccount = 'Failed to delete account';
  static const String savingGeminiApiKey = 'Saving Gemini API key...';
  static const String geminiApiKeyUpdated = 'Gemini API key updated';
  static const String failedToUpdateApiKey = 'Failed to update API key';
  static const String deleteAccountConfirm =
      'This will permanently delete your account data. Continue?';
  static const String enterGeminiApiKey = 'Enter your Gemini API key';
}

class HelpStrings {
  static const String header = 'Help Center';
  static const String userRoles = 'Roles & Permissions';
  static const String instructor = 'Instructor';
  static const String student = 'Student';
  static const String organizationAdmin = 'Organization/Admin';
  static const String comingSoon = 'Coming Soon';
  static const String gettingStarted = 'Quick Start';
  static const String forInstructors = 'For Instructors';
  static const String forStudents = 'For Students';
  static const String coreFeatures = 'Feature Guides';
  static const String subjectManagement = 'Subject Management';
  static const String aiExamGeneration = 'AI-Powered Exam Generation';
  static const String performanceTracking = 'Performance Tracking';
  static const String examTakingExperience = 'Exam Taking Experience';
  static const String notificationSystem = 'Notification System';
  static const String authenticationSecurity = 'Authentication & Security';
  static const String currentImplementation = 'Current Implementation';
  static const String futureSecurityFeatures = 'Future Security Features';
  static const String needMoreHelp = 'Need direct support?';
  static const String contactSupport =
      'Contact your instructor or system admin for account and access issues.';
  static const String soon = 'Soon';
}

class AboutStrings {
  static const String overview = 'What Is Smart Text Thief?';
  static const String overviewText1 =
      'Smart Text Thief helps instructors create high-quality exams quickly using AI.';
  static const String overviewText2 =
      'It supports the full exam workflow: creating, publishing, taking exams, and reviewing performance.';
  static const String keyConcept = 'Core Idea';
  static const String keyConceptText =
      'Make assessment creation faster while keeping control over quality, context, and difficulty.';
  static const String keyAdvantages = 'Why Instructors Use It';
  static const String technicalStack = 'Technology Stack';
  static const String frameworkLanguage = 'Framework & Language';
  static const String backendDatabase = 'Backend & Database';
  static const String aiMl = 'AI & ML';
  static const String additionalTechnologies = 'Additional Technologies';
  static const String vision = 'Vision';
  static const String visionText =
      'Our vision is to deliver fair, efficient, and insight-driven assessments while saving instructors significant manual effort.';
  static const String appInfoTitle = 'Platform Summary';
  static const String appInfoBody =
      'Designed for teachers and students to manage subjects, generate exams, and track outcomes in one place.';
}

class CreateExamStrings {
  static const String levelExam = 'Level Exam';
  static const String selectLevel = 'Select Level';
  static const String examNameHint = 'Enter exam Name';
  static const String examNameTitle = 'Name of Exam';
  static const String contentContextHint =
      'e.g., Religious, Scientific, Training, etc.';
  static const String contentContextTitle = 'Content Context';
  static const String geminiModelTitle = 'Gemini Model (Optional)';
  static const String geminiModelHint =
      'Leave empty to use gemini-2.5-flash';
  static const String unorderedQuestionsLabel =
      'Can each open exam have questions unordered?';
  static const String createExam = 'Create Exam';
  static const String creating = 'Creating....';

  static const String numberOfQuestions = 'Number of Questions';
  static const String multipleChoice = 'Multiple Choice';
  static const String trueFalse = 'True/False';
  static const String qa = 'Q&A';
  static const String examDurationMin = 'Exam Duration (Min)';
  static const String minOnly = 'Min Only';

  static const String uploadFiles = 'Upload Files';
  static const String chooseFiles = 'Choose Files';
  static const String clearAll = 'Clear All';
  static const String uploadedFiles = 'Uploaded Files';
  static const String filePermissionDenied =
      'File permission denied. No files were accessed.';
  static const String enterTextManually = 'Enter Text Manually';
  static const String enterOrPasteExamContent =
      'Enter or paste exam content here...';
  static const String selectDate = 'Select Date';
  static const String examDuration = 'Exam Duration';
  static const String startDate = 'Start Date';
  static const String endDate = 'End Date';
  static const String duration = 'Duration';
  static const String days = 'days';
  static const String fileTypePdf = 'PDF';
  static const String fileTypeImage = 'Image';

  static const String allFieldsRequired = 'All fields must be filled';
  static const String selectQuestionCount = 'You must select a number of questions';
  static const String minExamTime = 'Exam time cannot be less than 10 minutes';
  static const String specifyStartEnd = 'Please specify start and end time';
  static const String endAfterStart = 'End date must be after start date';
  static const String noFilesUploaded = 'No Files Uploaded';
  static const String noTextFound = 'No text found';
  static const String addGeminiKeyFirst =
      'Please add your Gemini API key from profile first';
  static const String generationFailed = 'Failed to generate exam questions';
  static const String createdDone = 'Created is Done';
  static const String uploadFilesSuccessSuffix = 'file(s) uploaded successfully';
  static const String errorPickingFilesPrefix = 'Error picking files';

  static String uploadedFilesCount(int count) => '$uploadedFiles ($count)';
  static String uploadFilesSuccess(int count) =>
      '$count $uploadFilesSuccessSuffix';
  static String errorPickingFiles(String error) =>
      '$errorPickingFilesPrefix: $error';
}

class ViewExamStrings {
  static const String questionsEditMode = 'Questions (Edit Mode)';
  static const String results = 'Results';
  static const String from = 'From';
  static const String saveAndSubmit = 'Save && Submit';
  static const String saving = 'Saving';
  static const String selectStudent = 'Select Student';
  static const String level = 'Level';
  static const String questions = 'Questions';
  static const String questionLabel = 'Question:';
  static const String options = 'Options:';
  static const String optionsEditMode = 'Options (Tap to select correct answer):';
  static const String correctAnswer = 'Correct Answer:';
  static const String studentAnswer = 'Student Answer:';
  static const String score = 'Score';
  static const String errorSaving = 'Error to Saved... please Try Again Later';
  static const String uploaded = 'Uploaded';

  static String resultsTitle(int scoreValue, int totalQuestions) =>
      '$results($scoreValue $from $totalQuestions)';
}

class DoExamStrings {
  static const String examFinished = 'Exam finished!';
  static const String error = 'Error';
  static const String noQuestionsAvailable = 'No questions available in this exam';
  static const String question = 'Question';
  static const String of = 'of';
  static const String writeAnswerHere = 'Write your answer here...';
  static const String previous = 'Previous';
  static const String submitExam = 'Submit Exam';
  static const String next = 'Next';
  static const String exitExam = 'Exit Exam?';
  static const String exitExamConfirm =
      'Are you sure you want to exit the exam? Your progress will be saved.';
  static const String exit = 'Exit';
  static const String incompleteExam = 'Incomplete Exam';
  static const String unansweredSuffix = 'unanswered question(s).';
  static const String unansweredHint =
      'Please answer all questions before submitting.';

  static String questionProgress(int current, int total) =>
      '$question $current $of $total';
  static String timerText(String minutes, String seconds) =>
      '$minutes:$seconds';
  static String unansweredText(int count) =>
      'You have $count $unansweredSuffix\n\n$unansweredHint';
}

class DataSourceStrings {
  static const String subjectCreationError =
      'An error occurred while creating the subject.';
  static const String invalidSubjectCode =
      'Invalid subject code. Please try again.';
  static const String subjectClosed =
      'This subject is closed by the teacher right now.';

  static String subjectJoinedBody(
    String userName,
    String subjectName,
    int membersCount,
  ) {
    final suffix = membersCount > 1 ? 'and $membersCount members' : '';
    return '$userName has joined $subjectName $suffix';
  }

  static String examCreatedBody(
    String specialIdLiveExam,
    String subjectName,
    String startsAfter,
    String endsAfter,
  ) =>
      'New Exam Created $specialIdLiveExam in $subjectName\n$startsAfter and $endsAfter';

  static String examSubmittedBody(
    String userName,
    String examType,
    String specialIdLiveExam,
    int membersCount,
  ) {
    final suffix = membersCount <= 0 ? '' : 'and $membersCount members';
    return '$userName Submitted Exam $examType $specialIdLiveExam $suffix';
  }
}
