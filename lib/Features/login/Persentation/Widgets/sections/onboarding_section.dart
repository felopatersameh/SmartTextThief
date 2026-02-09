import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../Core/Resources/resources.dart';
import 'indicators.dart';
import 'login_layout_spec.dart';
import 'onboarding_card.dart';

class LoginOnboardingSection extends StatelessWidget {
  const LoginOnboardingSection({
    super.key,
    required this.layout,
    required this.items,
    required this.currentPage,
    required this.pageController,
    required this.onPageChanged,
  });

  final LoginLayoutSpec layout;
  final List<OnboardingItemData> items;
  final int currentPage;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: layout.onboardingPadding,
      decoration: BoxDecoration(
        color: AppColors.colorsBackGround2.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.colorTextFieldBackGround.withValues(alpha: 0.85),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: items.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) => OnboardingCard(
                item: items[index],
                compact: layout.compact,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          LoginIndicators(
            count: items.length,
            currentIndex: currentPage,
          ),
        ],
      ),
    );
  }
}
