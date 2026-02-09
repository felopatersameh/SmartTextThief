import 'package:flutter/material.dart';

import 'app_icons.dart';
import 'strings.dart';

class OnboardingItemData {
  const OnboardingItemData({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class AppList {
  static const List<OnboardingItemData> onboardingItems = [
    OnboardingItemData(
      title: LoginStrings.onboardingCreateExamsTitle,
      description: LoginStrings.onboardingCreateExamsDesc,
      icon: AppIcons.quiz,
    ),
    OnboardingItemData(
      title: LoginStrings.onboardingManageSubjectsTitle,
      description: LoginStrings.onboardingManageSubjectsDesc,
      icon: AppIcons.subject,
    ),
    OnboardingItemData(
      title: LoginStrings.onboardingTrackResultsTitle,
      description: LoginStrings.onboardingTrackResultsDesc,
      icon: AppIcons.people,
    ),
  ];

  static const List<String> monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> weekDaysShort = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> helpInstructorFeatures = [
    'Create and manage subjects',
    'Generate AI-powered exams',
    'Monitor student performance',
    'Access detailed analytics',
  ];

  static const List<String> helpStudentFeatures = [
    'Join subjects using unique codes',
    'Take online exams',
    'View results and answers after deadline',
    'Track personal progress',
  ];

  static const List<String> helpAdminFeatures = [
    'Manage institutional accounts',
    'Approve/reject user registrations',
    'Add emails with designated roles',
    'Complete organizational oversight',
    'Institution-wide analytics',
  ];

  static const List<String> helpInstructorGettingStarted = [
    'Sign up with Google or Email',
    'Create your first subject',
    'Generate subject code',
    'Share code with students',
    'Create exams using AI',
    'Publish and monitor student performance',
  ];

  static const List<String> helpStudentGettingStarted = [
    'Sign up with Google or Email',
    'Enter subject code from instructor',
    'Wait for exams to be published',
    'Take exams during scheduled time',
    'View results and learn from answers',
  ];

  static const List<String> helpSubjectManagement = [
    'Create unlimited subjects',
    'Generate unique subject codes',
    'Organize courses by semester',
    'Search and filter subjects easily',
  ];

  static const List<String> helpAiExamGeneration = [
    'Upload PDF files',
    'Upload images (text extracted)',
    'Direct text input',
    'Add context for better quality',
    'Choose Gemini model (default: gemini-2.5-flash)',
    'Shuffle questions per student',
    'Set difficulty levels',
    'Edit questions before publishing',
    'Export professional PDFs',
  ];

  static const List<String> helpPerformanceTracking = [
    'View student results',
    'Detailed score breakdowns',
    'Performance analytics per subject',
    'Real-time notifications',
  ];

  static const List<String> helpExamTakingExperience = [
    'Start after scheduled time',
    'Clean, distraction-free interface',
    'Immediate result display',
    'Short-answer grading based on meaning',
    'View answers after deadline',
    'Personal grade history',
  ];

  static const List<String> helpNotifications = [
    'New exam publications',
    'Exam results availability',
    'Subject updates',
    'Answer key releases',
    'Administrative announcements',
  ];

  static const List<String> helpCurrentAuthFeatures = [
    'Google Authentication (Sign in with Google)',
    'Email/Password registration',
    'Institution/School selection during signup',
    'Role selection (Instructor/Student)',
  ];

  static const List<String> helpFutureSecurityFeatures = [
    'Email verification required',
    'Organization approval system',
    'Role-based access control',
    'Secure exam delivery',
  ];

  static const List<(String, String, String)> aboutAdvantages = [
    ('⚡', 'Speed', 'Generate comprehensive exams in minutes, not hours'),
    ('🎨', 'Flexibility', 'Multiple input formats (PDF, images, text, documents)'),
    ('🔀', 'Fairness', 'Question shuffling prevents cheating'),
    ('📊', 'Insights', 'Detailed performance analytics'),
    ('🤖', 'AI-Powered', "Leverages Google's Gemini AI for intelligent question generation"),
    ('📱', 'Cross-Platform', 'Works on iOS and Android'),
    ('☁️', 'Cloud-Based', 'Access from anywhere, data always synced'),
    ('🔔', 'Real-Time', 'Instant notifications and updates'),
    ('📈', 'Scalable', 'Supports institutions of any size'),
  ];

  static const List<String> aboutFrameworkLanguage = [
    'Flutter - Cross-platform mobile development',
    'Dart - Programming language',
  ];

  static const List<String> aboutBackendDatabase = [
    'Firebase Firestore - NoSQL cloud database',
    'Firebase Realtime Database - Real-time sync',
    'Firebase Cloud Messaging (FCM) - Push notifications',
  ];

  static const List<String> aboutAiMl = [
    'Google Generative AI - Gemini AI model',
    'Custom-engineered prompts - Optimized quality',
    'Google ML Kit - Text recognition (OCR)',
  ];

  static const List<String> aboutAdditionalTechnologies = [
    'Google Authentication - Secure OAuth 2.0',
    'Cubit - State management',
    'Hive - Local storage',
    'go_router - Navigation',
    'flutter_screenutil - Responsive design',
    'Syncfusion PDF - PDF creation',
  ];
}
