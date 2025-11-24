// about_screen.dart
import 'package:flutter/material.dart';
import '../../../../Core/Resources/app_fonts.dart';
import '../../../../Core/Resources/app_colors.dart';

import '../../../../Config/Routes/name_routes.dart';
import '../../../../Core/Utils/Widget/custom_text_app.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorsBackGround,
      appBar: AppBar(title: Text(NameRoutes.help.titleAppBar)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Icon(
                Icons.help_outline_rounded,
                size: 60,
                color: AppColors.colorPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: AppCustomText.generate(
                text: 'How can we help you?',
                textStyle: AppTextStyles.h5Bold.copyWith(
                  color: AppColors.colorPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // User Roles Section
            _buildSectionTitle('👥 User Roles'),
            const SizedBox(height: 12),
            _buildRoleCard('👨‍🏫 Instructor', [
              'Create and manage subjects',
              'Generate AI-powered exams',
              'Monitor student performance',
              'Access detailed analytics',
            ]),
            const SizedBox(height: 12),
            _buildRoleCard('🎓 Student', [
              'Join subjects using unique codes',
              'Take online exams',
              'View results and answers after deadline',
              'Track personal progress',
            ]),
            const SizedBox(height: 12),
            _buildRoleCard('🏢 Organization/Admin (Coming Soon)', [
              'Manage institutional accounts',
              'Approve/reject user registrations',
              'Add emails with designated roles',
              'Complete organizational oversight',
              'Institution-wide analytics',
            ], isComingSoon: true),
            const SizedBox(height: 24),

            // Getting Started Section
            _buildSectionTitle('🚀 Getting Started'),
            const SizedBox(height: 12),
            _buildExpansionCard(0, '👨‍🏫 For Instructors', [
              'Sign up with Google or Email',
              'Select your institution',
              'Create your first subject',
              'Generate subject code',
              'Share code with students',
              'Create exams using AI',
              'Monitor student performance',
            ]),
            const SizedBox(height: 12),
            _buildExpansionCard(1, '🎓 For Students', [
              'Sign up with Google or Email',
              'Select your institution',
              'Enter subject code from instructor',
              'Wait for exams to be published',
              'Take exams during scheduled time',
              'View results and learn from answers',
            ]),
            const SizedBox(height: 24),

            // Core Features Section
            _buildSectionTitle('✨ Core Features'),
            const SizedBox(height: 12),
            _buildExpansionCard(2, '📚 Subject Management', [
              'Create unlimited subjects',
              'Generate unique subject codes',
              'Organize courses by semester',
              'Search and filter subjects easily',
            ]),
            const SizedBox(height: 12),
            _buildExpansionCard(3, '🤖 AI-Powered Exam Generation', [
              'Upload PDF files',
              'Upload images (text extracted)',
              'Upload any document file',
              'Direct text input',
              'Add context for better quality',
              'Shuffle questions per student',
              'Set difficulty levels',
              'Edit questions before publishing',
              'Export professional PDFs',
            ]),
            const SizedBox(height: 12),
            _buildExpansionCard(4, '📊 Performance Tracking', [
              'View student results',
              'Detailed score breakdowns',
              'Performance analytics per subject',
              'Real-time notifications',
            ]),
            const SizedBox(height: 12),
            _buildExpansionCard(5, '📱 Exam Taking Experience', [
              'Start after scheduled time',
              'Clean, distraction-free interface',
              'Immediate result display',
              'View answers after deadline',
              'Personal grade history',
            ]),
            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionTitle('🔔 Notification System'),
            const SizedBox(height: 12),
            _buildInfoCard([
              'New exam publications',
              'Exam results availability',
              'Subject updates',
              'Answer key releases',
              'Administrative announcements',
            ]),
            const SizedBox(height: 24),

            // Authentication Section
            _buildSectionTitle('🔐 Authentication & Security'),
            const SizedBox(height: 12),
            _buildAuthCard('Current Implementation', [
              'Google Authentication (Sign in with Google)',
              'Email/Password registration',
              'Institution/School selection during signup',
              'Role selection (Instructor/Student)',
            ], false),
            const SizedBox(height: 12),
            _buildAuthCard('Future Security Features', [
              'Email verification required',
              'Organization approval system',
              'Role-based access control',
              'Secure exam delivery',
            ], true),
            const SizedBox(height: 32),

            // Contact Support
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      AppColors.colorsBackGround2, // Darker background for card
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.support_agent_rounded,
                      size: 40,
                      color: AppColors.colorPrimary,
                    ),
                    const SizedBox(height: 8),
                    AppCustomText.generate(
                      text: 'Need more help?',
                      textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AppCustomText.generate(
                      text: 'Contact our support team',
                      textStyle: AppTextStyles.bodySmallMedium.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return AppCustomText.generate(
      text: title,
      textStyle: AppTextStyles.h6Bold.copyWith(color: AppColors.textWhite),
    );
  }

  Widget _buildRoleCard(
    String title,
    List<String> features, {
    bool isComingSoon = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.colorsBackGround2, // Darker background for card
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.colorPrimary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppCustomText.generate(
                  text: title,
                  textStyle: AppTextStyles.bodyMediumBold.copyWith(
                    color: AppColors.colorPrimary,
                  ),
                ),
              ),
              if (isComingSoon)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppCustomText.generate(
                    text: 'Soon',
                    textStyle: AppTextStyles.bodySmallMedium.copyWith(
                      color: AppColors.textWhite,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: AppColors.colorPrimary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppCustomText.generate(
                      text: feature,
                      textStyle: AppTextStyles.bodySmallMedium.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionCard(int index, String title, List<String> items) {
    final isExpanded = _expandedIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.colorsBackGround2, // Darker background for card
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.colorPrimary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: AppCustomText.generate(
                      text: title,
                      textStyle: AppTextStyles.bodyMediumBold.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.colorPrimary,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: items.asMap().entries.map((entry) {
                  final number = entry.key + 1;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.colorPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$number',
                              style: AppTextStyles.bodySmallMedium.copyWith(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppCustomText.generate(
                            text: item,
                            textStyle: AppTextStyles.bodySmallMedium.copyWith(
                              color: AppColors.textWhite.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.colorsBackGround2, // Darker background for card
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.colorPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 18,
                      color: AppColors.colorPrimary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppCustomText.generate(
                        text: item,
                        textStyle: AppTextStyles.bodySmallMedium.copyWith(
                          color: AppColors.textWhite.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildAuthCard(String title, List<String> items, bool isFuture) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.colorsBackGround2, // Darker background for card
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.colorPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isFuture ? Icons.upcoming : Icons.verified_user,
                color: AppColors.colorPrimary,
              ),
              const SizedBox(width: 8),
              AppCustomText.generate(
                text: title,
                textStyle: AppTextStyles.bodyMediumBold.copyWith(
                  color: AppColors.colorPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isFuture ? Icons.schedule : Icons.check_circle,
                    size: 18,
                    color: AppColors.colorPrimary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppCustomText.generate(
                      text: item,
                      textStyle: AppTextStyles.bodySmallMedium.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
