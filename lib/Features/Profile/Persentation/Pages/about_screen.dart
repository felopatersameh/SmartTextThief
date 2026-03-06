import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../Config/Routes/name_routes.dart';
import '../../../../Core/Resources/resources.dart';
import '../../../../Core/Utils/Widget/custom_text_app.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorsBackGround,
      appBar: AppBar(title: Text(NameRoutes.about.titleAppBar)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                AppConstants.appLogoAsset,
                height: 100.h,
              ),
            ),
            SizedBox(height: 12.h),
            _buildSectionTitle('App Information'),
            SizedBox(height: 10.h),
            _buildAppInfoCard(),
            SizedBox(height: 16.h),
            _buildSectionTitle('Developer'),
            SizedBox(height: 10.h),
            _buildSimpleInfoCard(
              title: 'Developer Name',
              value: 'felopater sameh',
            ),
            SizedBox(height: 8.h),
            _buildSimpleInfoCard(
              title: 'Email',
              value: 'felopaters37@gmail.com',
            ),
            SizedBox(height: 16.h),
            _buildSectionTitle('Technical Info'),
            SizedBox(height: 10.h),
            _buildSimpleInfoCard(
              title: 'Backend API',
              value: 'Dart Frog Framework',
            ),
            SizedBox(height: 8.h),
            _buildSimpleInfoCard(
              title: 'Database',
              value: 'MongoDB',
            ),
            SizedBox(height: 16.h),
            _buildSectionTitle('Core Capabilities'),
            SizedBox(height: 10.h),
            _buildSimpleInfoCard(
              title: 'Exam Analytics',
              value:
                  'Each exam has its own analysis with performance indicators and score distribution.',
            ),
            SizedBox(height: 8.h),
            _buildSimpleInfoCard(
              title: 'Subject Analytics',
              value:
                  'Each subject has dashboard-level analysis and exam-level insights for instructors.',
            ),
            SizedBox(height: 8.h),
            _buildSimpleInfoCard(
              title: 'User Analytics',
              value:
                  'Each user has personal analytics and progress insights based on activity and results.',
            ),
            SizedBox(height: 8.h),
            _buildSimpleInfoCard(
              title: 'AI Model Strategy',
              value:
                  'The app supports multiple Gemini models. If one model reaches limits, requests move to the next configured model.',
            ),
            SizedBox(height: 8.h),
            _buildSimpleInfoCard(
              title: 'Teacher Control',
              value:
                  'Instructors have expanded control over subject structure, exam behavior, and monitoring.',
            ),
            SizedBox(height: 8.h),
            _buildSimpleInfoCard(
              title: 'Student Personal Assessment',
              value:
                  'Students receive personal result context to support targeted improvement.',
            ),
            SizedBox(height: 16.h),
            _buildSectionTitle('Future Plans'),
            SizedBox(height: 10.h),
            _buildSimpleInfoCard(
              title: 'Planned Modules',
              value:
                  'Subscription plans, teacher workshops, ads support, and multi-language support are part of the roadmap.',
            ),
            SizedBox(height: 8.h),
            _buildSimpleInfoCard(
              title: 'Easy UX with High Quality',
              value:
                  'Product direction prioritizes easier daily usage while keeping high output quality.',
            ),
            SizedBox(height: 16.h),
            _buildSectionTitle('Legal Links'),
            SizedBox(height: 10.h),
            _buildSimpleInfoCard(
              title: 'Privacy Policy',
              value: 'Hosted on Firebase (privacy.html)',
            ),
            SizedBox(height: 8.h),
            _buildSimpleInfoCard(
              title: 'Terms of Service',
              value: 'Hosted on Firebase (terms.html)',
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.colorsBackGround2,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.colorPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final appName = snapshot.data?.appName ?? 'Examora';
          final version = snapshot.data == null
              ? 'Unknown'
              : '${snapshot.data!.version}+${snapshot.data!.buildNumber}';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoLine('App Name', appName),
              SizedBox(height: 6.h),
              _buildInfoLine('Version', version),
              SizedBox(height: 6.h),
              _buildInfoLine(
                'Description',
                'Examora helps instructors create and manage exams quickly.',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return AppCustomText.generate(
      text: title,
      textStyle: AppTextStyles.h6Bold.copyWith(color: AppColors.textWhite),
    );
  }

  Widget _buildSimpleInfoCard({
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.colorsBackGround2,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.colorPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: _buildInfoLine(title, value),
    );
  }

  Widget _buildInfoLine(String title, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$title: ',
            style: AppTextStyles.bodyMediumBold.copyWith(
              color: AppColors.colorPrimary,
            ),
          ),
          TextSpan(
            text: value,
            style: AppTextStyles.bodySmallMedium.copyWith(
              color: AppColors.textWhite.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}


