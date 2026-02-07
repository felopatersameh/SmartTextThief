import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:sahih_validator/sahih_validator.dart';

import '../../../../Resources/app_icons.dart';
import 'password_visibility_cubit.dart';
import '../build_text_field.dart';

class CustomPasswordTextFromField extends StatelessWidget {
  final TextEditingController controller;
  final String fieldId;
  final bool showForgetMessage;
  final bool isLogin;

  final String hintText;

  const CustomPasswordTextFromField({
    super.key,
    required this.controller,
    required this.fieldId,
    this.showForgetMessage = true,
    required this.hintText,
    this.isLogin = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PasswordVisibilityCubit(),
      child: BlocBuilder<PasswordVisibilityCubit, Map<String, bool>>(
        builder: (context, state) {
          final isVisible = state[fieldId] ?? false;
          return AppTextField(
            pressedIcon: () {},
            suffixIcon: IconButton(
              icon: isVisible
                  ? Icon(
                      AppIcons.notVisibility,
                      color: Colors.white,
                    )
                  : Icon(
                      AppIcons.visibility,
                      color: Colors.white,
                    ),
              onPressed: () {
                context
                    .read<PasswordVisibilityCubit>()
                    .togglePasswordVisibility(fieldId);
              },
            ),
            controller: controller,
            hint: hintText,
            isShow: !isVisible,
            validator: (p0) {
              if (isLogin) {
                return SahihValidator.loginPassword(password: p0 ?? "");
              }
              return SahihValidator.passwordParts(p0 ?? "");
            },
            keyboard: TextInputType.visiblePassword,
            // prefixIcon: Icon(AppIcons.password),
            title: 'Password ',
          );
        },
      ),
    );
  }
}
