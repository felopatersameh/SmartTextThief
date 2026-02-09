import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../Core/Resources/resources.dart';
import '../../../../../Core/Utils/Widget/ButtonsStyle/build_button_app_with_icon.dart';
import 'login_layout_spec.dart';

class LoginActionSection extends StatelessWidget {
  const LoginActionSection({
    super.key,
    required this.layout,
    required this.onGoogleSignInPressed,
  });

  final LoginLayoutSpec layout;
  final Future<void> Function() onGoogleSignInPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: layout.actionPadding,
      decoration: BoxDecoration(
        color: AppColors.colorsBackGround2.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.colorPrimary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BuildButtonAppWithIcon(
            actions: () async => await onGoogleSignInPressed(),
            iconErrorBuilder: AppIcons.google,
            text: AppStrings.orSignInWithGoogle,
            textIcon: '',
            height: layout.buttonHeight,
            backgroundColor: AppColors.colorsBackGround.withValues(alpha: 0.45),
            borderColor: AppColors.colorPrimary.withValues(alpha: 0.35),
            textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
              color: AppColors.textWhite,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppStrings.welcomeHint,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppTextStyles.bodySmallMedium.copyWith(
              color: AppColors.textCoolGray,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
