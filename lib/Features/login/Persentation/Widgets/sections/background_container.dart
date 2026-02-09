import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../Core/Resources/resources.dart';

class BackgroundContainer extends StatelessWidget {
  const BackgroundContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.colorsBackGround,
                AppColors.colorsBackGround2,
              ],
            ),
          ),
          child: const SizedBox.expand(),
        ),
        Positioned(
          top: -90.h,
          right: -45.w,
          child: _BackgroundCircle(
            size: 240.r,
            color: AppColors.colorPrimary.withValues(alpha: 0.2),
          ),
        ),
        Positioned(
          bottom: -120.h,
          left: -70.w,
          child: _BackgroundCircle(
            size: 270.r,
            color: AppColors.info.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }
}

class _BackgroundCircle extends StatelessWidget {
  const _BackgroundCircle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
