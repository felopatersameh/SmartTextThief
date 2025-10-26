import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../Core/Resources/app_colors.dart';
import '../../../../../Core/Resources/app_fonts.dart';
import '../../../../../Core/Utils/Widget/custom_text_app.dart';

class CreateButton extends StatelessWidget {
  final String text ;
  final void Function()? onPress ;
  const CreateButton({super.key, required this.text, required this.onPress});

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.colorPrimary,
          disabledBackgroundColor: AppColors.colorsBackGround,
          disabledForegroundColor: AppColors.colorsBackGround,
          overlayColor: AppColors.colorsBackGround,
          surfaceTintColor: AppColors.colorsBackGround,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
        ),
        onPressed:onPress,
        child:AppCustomtext(
          text:  text,
          textStyle: AppTextStyles.bodyLargeBold,
        ),
      ),
    );
  }
}
