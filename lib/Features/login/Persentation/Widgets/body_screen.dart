import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../Config/Routes/app_router.dart';
import '../Cubit/authentication_cubit.dart';

import '../../../../Core/Resources/resources.dart';
import '../../../../Core/Utils/Widget/ButtonsStyle/build_button_app_with_icon.dart';
import '../../../../Core/Utils/Widget/custom_text_app.dart';
import '../../../../Core/Utils/show_message_snack_bar.dart';

class BodyScreen extends StatefulWidget {
  const BodyScreen({super.key});

  @override
  State<BodyScreen> createState() => _BodyScreenState();
}

class _BodyScreenState extends State<BodyScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingItemData> _items = AppList.onboardingItems;

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) async {
        if (state.success != null &&
            state.message?.isNotEmpty == true &&
            state.message != null) {
          if (state.success == true) {
            await showMessageSnackBar(
              context,
              title: state.message!,
              type: MessageType.success,
            );
            if (!context.mounted) return;
            if (state.requireRoleSelection) {
              AppRouter.pushToChooseRole(context);
            } else {
              AppRouter.pushToMainScreen(context);
            }
          }
          if (state.success == false) {
            if (!context.mounted) return;
            await showMessageSnackBar(
              context,
              title: state.message!,
              type: MessageType.error,
            );
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 8.h),
            Container(
              width: 78.w,
              height: 78.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.colorPrimary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.r),
                child: Image.asset(
                  AppConstants.appLogoAsset,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 25.h),
            AppCustomText.generate(
              text: AppStrings.welcome,
              textStyle: AppTextStyles.h3Bold,
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: .9.sw),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 400.h,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _items.length,
                          onPageChanged: (index) {
                            if (!mounted) return;
                            setState(() => _currentPage = index);
                          },
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return _OnboardingCard(item: item);
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _items.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            width: _currentPage == index ? 22.w : 8.w,
                            height: 8.h,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppColors.colorPrimary
                                  : AppColors.colorUnActiveIcons.withValues(
                                      alpha: 0.55,
                                    ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      BuildButtonAppWithIcon(
                        actions: () async => await showMessageSnackBar(
                          context,
                          title: LoginStrings.loadingGoogleSignIn,
                          type: MessageType.loading,
                          onLoading: () async =>
                              await context
                                  .read<AuthenticationCubit>()
                                  .loginByGoogle(
                                    context,
                                  ),
                        ),
                        iconErrorBuilder: AppIcons.google,
                        text: AppStrings.orSignInWithGoogle,
                        textIcon: "",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  final OnboardingItemData item;

  const _OnboardingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 22.h),
        padding: EdgeInsets.all(22.w),
        decoration: BoxDecoration(
          color: AppColors.colorsBackGround2,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.colorTextFieldBackGround.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 150.h,
              decoration: BoxDecoration(
                color: AppColors.colorPrimary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: AppColors.colorPrimary,
                size: 30.sp,
              ),
            ),
            SizedBox(height: 18.h),
            AppCustomText.generate(
              text: item.title,
              textStyle: AppTextStyles.h6Bold,
            ),
            SizedBox(height: 10.h),
            AppCustomText.generate(
              text: item.description,
              textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
                color: AppColors.grey500,
              ),
              maxLines: 5,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
