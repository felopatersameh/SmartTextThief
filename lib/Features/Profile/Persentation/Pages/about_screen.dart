import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../Core/Resources/app_fonts.dart';
import '../../../../Core/Resources/app_colors.dart';

import '../../../../Config/Routes/name_routes.dart';
import '../../../../Core/Utils/Widget/custom_text_app.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorsBackGround,
      appBar: AppBar(title: Text(NameRoutes.about.titleAppBar)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image/Logo (Optional - if you have one)
            Center(
              child: Image.asset(
                'assets/Image/s2.png', // Replace with your logo path
                height: 100.h,
              ),
            ),
            // const SizedBox(height: 24),

            // Overview Section
            _buildSectionTitle('📚 Overview'),
            const SizedBox(height: 12),
            AppCustomText.generate(
              text:
                  'Smart Text Thief is a revolutionary educational platform that enables instructors to create comprehensive exams faster than traditional methods using AI technology.',
              textStyle: AppTextStyles.bodySmallMedium.copyWith(
                color: AppColors.textWhite,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            AppCustomText.generate(
              text:
                  'The system bridges the gap between instructors and students, providing a complete exam lifecycle management solution.',
              textStyle: AppTextStyles.bodySmallMedium.copyWith(
                color: AppColors.textWhite,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),

            // Key Concept Section
            _buildSectionTitle('💡 Key Concept'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.colorPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.colorPrimary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: AppCustomText.generate(
                text:
                    'Create exams with AI faster than any instructor could manually, while maintaining quality and customization options.',
                textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Key Advantages Section
            _buildSectionTitle('⭐ Key Advantages'),
            const SizedBox(height: 12),
            _buildAdvantageItem(
              '⚡',
              'Speed',
              'Generate comprehensive exams in minutes, not hours',
            ),
            _buildAdvantageItem(
              '🎨',
              'Flexibility',
              'Multiple input formats (PDF, images, text, documents)',
            ),
            _buildAdvantageItem(
              '🔀',
              'Fairness',
              'Question shuffling prevents cheating',
            ),
            _buildAdvantageItem(
              '📊',
              'Insights',
              'Detailed performance analytics',
            ),
            _buildAdvantageItem(
              '🤖',
              'AI-Powered',
              'Leverages Google\'s Gemini AI for intelligent question generation',
            ),
            _buildAdvantageItem(
              '📱',
              'Cross-Platform',
              'Works on iOS and Android',
            ),
            _buildAdvantageItem(
              '☁️',
              'Cloud-Based',
              'Access from anywhere, data always synced',
            ),
            _buildAdvantageItem(
              '🔔',
              'Real-Time',
              'Instant notifications and updates',
            ),
            _buildAdvantageItem(
              '📈',
              'Scalable',
              'Supports institutions of any size',
            ),
            const SizedBox(height: 24),

            // Technical Stack Section
            _buildSectionTitle('🛠️ Technical Stack'),
            const SizedBox(height: 12),
            _buildTechStackCard('Framework & Language', [
              'Flutter - Cross-platform mobile development',
              'Dart - Programming language',
            ]),
            const SizedBox(height: 12),
            _buildTechStackCard('Backend & Database', [
              'Firebase Firestore - NoSQL cloud database',
              'Firebase Realtime Database - Real-time sync',
              'Firebase Cloud Messaging (FCM) - Push notifications',
            ]),
            const SizedBox(height: 12),
            _buildTechStackCard('AI & ML', [
              'Google Generative AI - Gemini AI model',
              'Custom-engineered prompts - Optimized quality',
              'Google ML Kit - Text recognition (OCR)',
            ]),
            const SizedBox(height: 12),
            _buildTechStackCard('Additional Technologies', [
              'Google Authentication - Secure OAuth 2.0',
              'Cubit - State management',
              'Hive - Local storage',
              'go_router - Navigation',
              'flutter_screenutil - Responsive design',
              'Syncfusion PDF - PDF creation',
            ]),
            const SizedBox(height: 24),

            // Vision Section
            _buildSectionTitle('🔮 Vision'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.colorPrimary.withValues(alpha: 0.1),
                    AppColors.colorPrimary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppCustomText.generate(
                text:
                    'Smart Text Thief aims to become the leading AI-powered educational assessment platform, empowering institutions worldwide to deliver fair, efficient, and insightful examinations while saving instructors countless hours of manual work.',
                textStyle: AppTextStyles.bodySmallMedium.copyWith(
                  color: AppColors.textWhite,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 32),
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

  Widget _buildAdvantageItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCustomText.generate(
                  text: title,
                  textStyle: AppTextStyles.bodyMediumBold.copyWith(
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 4),
                AppCustomText.generate(
                  text: description,
                  textStyle: AppTextStyles.bodySmallMedium.copyWith(
                    color: AppColors.textWhite.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechStackCard(String title, List<String> items) {
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
          AppCustomText.generate(
            text: title,
            textStyle: AppTextStyles.bodyMediumBold.copyWith(
              color: AppColors.colorPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
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
