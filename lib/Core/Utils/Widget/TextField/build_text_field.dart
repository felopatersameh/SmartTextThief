import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../Resources/app_colors.dart';
import '../../../Resources/app_fonts.dart';

class AppTextField extends StatelessWidget {
  final FormFieldValidator<String> validator;
  final Widget ? prefixIcon;
  final TextEditingController controller;
  final TextInputType keyboard;
  final Widget? suffixIcon;
  final void Function()? pressedIcon;
  final bool? isShow;
  final String hint;
  final String ? title;

  const AppTextField({
    super.key,
    required this.validator,
     this.prefixIcon,
    required this.controller,
    required this.keyboard,
    this.suffixIcon,
    this.pressedIcon,
    this.isShow,
    required this.hint,
     this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      
        SizedBox(height: 16.h,),  
        TextFormField(
          enableSuggestions: true,
          autocorrect: true,
          controller: controller,
          keyboardType: keyboard,
          validator: validator,
          obscureText: isShow ?? false,
          style: AppTextStyles.bodyLargeMedium,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 16.h,
            ),
              fillColor: AppColors.colorTextFieldBackGround,
              filled: true,
              hintText: "  $hint",
              hintStyle: AppTextStyles.bodyLargeMedium.copyWith(color: Colors.grey.shade600,),
              prefixIcon: prefixIcon,
              prefixIconColor: AppColors.colorIcons,
              suffixIcon: suffixIcon,
              isCollapsed: true),
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }
}
