import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginLayoutSpec {
  const LoginLayoutSpec({
    required this.compact,
    required this.maxWidth,
    required this.outerPadding,
    required this.verticalGap,
    required this.onboardingPadding,
    required this.actionPadding,
    required this.buttonHeight,
  });

  final bool compact;
  final double maxWidth;
  final EdgeInsets outerPadding;
  final double verticalGap;
  final EdgeInsets onboardingPadding;
  final EdgeInsets actionPadding;
  final double buttonHeight;

  factory LoginLayoutSpec.fromSize(Size size) {
    final compact = size.height < 760 || size.width < 360;
    return LoginLayoutSpec(
      compact: compact,
      maxWidth: 520.w,
      outerPadding: EdgeInsets.symmetric(
        horizontal: compact ? 12.w : 18.w,
        vertical: 10.h,
      ),
      verticalGap: compact ? 10.h : 14.h,
      onboardingPadding: EdgeInsets.all(compact ? 10.w : 14.w),
      actionPadding: EdgeInsets.all(compact ? 10.w : 12.w),
      buttonHeight: compact ? 48.h : 50.h,
    );
  }
}
