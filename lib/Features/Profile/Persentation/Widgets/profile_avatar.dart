import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../Core/Resources/resources.dart';
import '../../../../Core/Utils/Widget/custom_text_app.dart';

class ProfileAvatar extends StatelessWidget {
  final String name;
  final String email;
  final String? imageUrl;
  final bool isAdmin;

  const ProfileAvatar({
    super.key,
    required this.name,
    required this.email,
    this.imageUrl,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: () {
                if (imageUrl != null && imageUrl!.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      constraints: BoxConstraints(
                        maxHeight: 150.h,
                        maxWidth: 150.w,
                      ),
                      backgroundColor: AppColors.colorPrimary.withAlpha(200),
                      shape: CircleBorder(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(color: AppColors.transparent),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: Image.network(
                              imageUrl!,
                              filterQuality: FilterQuality.high,
                              width: 250.w,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildFallbackAvatar();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
              child: ClipOval(
                child: Image.network(
                  imageUrl ?? '',
                  width: 100.r,
                  height: 100.r,
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildFallbackAvatar();
                  },
                ),
              ),
            ),

            // EDIT icon if admin
            if (isAdmin)
              Positioned(
                child: CircleAvatar(
                  radius: 14.r,
                  backgroundColor: AppColors.colorPrimary,
                  child: Icon(
                    AppIcons.edit,
                    color: AppColors.textWhite,
                    size: 14.sp,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        AppCustomText.generate(text: name, textStyle: AppTextStyles.h5SemiBold),
        SizedBox(height: 4.h),
        AppCustomText.generate(
          text: email,
          textStyle: AppTextStyles.h7Medium.copyWith(color: AppColors.white70),
        ),
      ],
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      width: 150.r,
      height: 150.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.blueGrey,
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 30.sp,
          color: AppColors.textWhite,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
