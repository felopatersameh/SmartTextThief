import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../Config/Routes/name_routes.dart';
import '../../../../Core/Resources/resources.dart';
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                AppConstants.appLogoAsset,
                height: 100.h,
              ),
            ),
            _buildSectionTitle(AboutStrings.overview),
            const SizedBox(height: 12),
            AppCustomText.generate(
              text: AboutStrings.overviewText1,
              textStyle: AppTextStyles.bodySmallMedium.copyWith(
                color: AppColors.textWhite,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            AppCustomText.generate(
              text: AboutStrings.overviewText2,
              textStyle: AppTextStyles.bodySmallMedium.copyWith(
                color: AppColors.textWhite,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(AboutStrings.keyConcept),
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
                text: AboutStrings.keyConceptText,
                textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(AboutStrings.keyAdvantages),
            const SizedBox(height: 12),
            ...AppList.aboutAdvantages.map(
              (item) => _buildAdvantageItem(
                item.$1,
                item.$2,
                item.$3,
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(AboutStrings.technicalStack),
            const SizedBox(height: 12),
            _buildTechStackCard(
              AboutStrings.frameworkLanguage,
              AppList.aboutFrameworkLanguage,
            ),
            const SizedBox(height: 12),
            _buildTechStackCard(
              AboutStrings.backendDatabase,
              AppList.aboutBackendDatabase,
            ),
            const SizedBox(height: 12),
            _buildTechStackCard(
              AboutStrings.aiMl,
              AppList.aboutAiMl,
            ),
            const SizedBox(height: 12),
            _buildTechStackCard(
              AboutStrings.additionalTechnologies,
              AppList.aboutAdditionalTechnologies,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(AboutStrings.vision),
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
                text: AboutStrings.visionText,
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
        color: AppColors.colorsBackGround2,
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
                    AppIcons.checkCircleOutline,
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
