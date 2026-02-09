import 'package:flutter/material.dart';

import '../../../../Config/Routes/name_routes.dart';
import '../../../../Core/Resources/resources.dart';
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                AppIcons.helpOutlineRounded,
                size: 60,
                color: AppColors.colorPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: AppCustomText.generate(
                text: HelpStrings.header,
                textStyle: AppTextStyles.h5Bold.copyWith(
                  color: AppColors.colorPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickHintCard(),
            const SizedBox(height: 24),
            _buildSectionTitle(HelpStrings.userRoles),
            const SizedBox(height: 12),
            _buildRoleCard(
              HelpStrings.instructor,
              AppList.helpInstructorFeatures,
            ),
            const SizedBox(height: 12),
            _buildRoleCard(
              HelpStrings.student,
              AppList.helpStudentFeatures,
            ),
          
            const SizedBox(height: 24),
            _buildSectionTitle(HelpStrings.gettingStarted),
            const SizedBox(height: 12),
            _buildExpansionCard(
              0,
              HelpStrings.forInstructors,
              AppList.helpInstructorGettingStarted,
            ),
            const SizedBox(height: 12),
            _buildExpansionCard(
              1,
              HelpStrings.forStudents,
              AppList.helpStudentGettingStarted,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(HelpStrings.coreFeatures),
            const SizedBox(height: 12),
            _buildExpansionCard(
              2,
              HelpStrings.subjectManagement,
              AppList.helpSubjectManagement,
            ),
            const SizedBox(height: 12),
            _buildExpansionCard(
              3,
              HelpStrings.aiExamGeneration,
              AppList.helpAiExamGeneration,
            ),
            const SizedBox(height: 12),
            _buildExpansionCard(
              4,
              HelpStrings.performanceTracking,
              AppList.helpPerformanceTracking,
            ),
            const SizedBox(height: 12),
            _buildExpansionCard(
              5,
              HelpStrings.examTakingExperience,
              AppList.helpExamTakingExperience,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(HelpStrings.notificationSystem),
            const SizedBox(height: 12),
            _buildInfoCard(AppList.helpNotifications),
            const SizedBox(height: 24),
            _buildSectionTitle(HelpStrings.authenticationSecurity),
            const SizedBox(height: 12),
            _buildAuthCard(
              HelpStrings.currentImplementation,
              AppList.helpCurrentAuthFeatures,
              false,
            ),
            const SizedBox(height: 12),
            _buildAuthCard(
              HelpStrings.futureSecurityFeatures,
              AppList.helpFutureSecurityFeatures,
              true,
            ),
            const SizedBox(height: 32),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.colorsBackGround2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      AppIcons.supportAgentRounded,
                      size: 40,
                      color: AppColors.colorPrimary,
                    ),
                    const SizedBox(height: 8),
                    AppCustomText.generate(
                      text: HelpStrings.needMoreHelp,
                      textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AppCustomText.generate(
                      text: HelpStrings.contactSupport,
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

  Widget _buildQuickHintCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.colorsBackGround2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.colorPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            AppIcons.quizOutlined,
            color: AppColors.colorPrimary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppCustomText.generate(
              text:
                  'Use the sections below based on your role to quickly find setup steps and feature usage.',
              textStyle: AppTextStyles.bodySmallMedium.copyWith(
                color: AppColors.textWhite.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
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
        color: AppColors.colorsBackGround2,
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
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppCustomText.generate(
                    text: HelpStrings.soon,
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
                    AppIcons.checkCircleOutline,
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
        color: AppColors.colorsBackGround2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.colorPrimary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
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
                    isExpanded ? AppIcons.expandLess : AppIcons.expandMore,
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
        color: AppColors.colorsBackGround2,
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
                      AppIcons.notificationsActive,
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
        color: AppColors.colorsBackGround2,
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
                isFuture ? AppIcons.upcoming : AppIcons.verifiedUser,
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
                    isFuture ? AppIcons.schedule : AppIcons.checkCircle,
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
