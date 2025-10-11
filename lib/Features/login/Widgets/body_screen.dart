import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahih_validator/sahih_validator.dart';
import '../../../Config/Routes/name_routes.dart';
import '../../../Config/Routes/app_router.dart';
import '../cubit/authentication_cubit.dart';

import '../../../Core/Resources/resources.dart';
import '../../../Core/Utils/Widget/ButtonsStyle/build_button_app.dart';
import '../../../Core/Utils/Widget/ButtonsStyle/build_button_app_with_icon.dart';
import '../../../Core/Utils/Widget/TextField/PasswordVisibility/password_text__form_field.dart';
import '../../../Core/Utils/Widget/TextField/build_text_field.dart';
import '../../../Core/Utils/Widget/custom_text_app.dart';
import '../../../Core/Utils/show_message_snack_bar.dart';

class BodyScreen extends StatefulWidget {
  const BodyScreen({super.key});

  @override
  State<BodyScreen> createState() => _BodyScreenState();
}

class _BodyScreenState extends State<BodyScreen> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  @override
  void initState() {
    _emailController.clear();
    _passwordController.clear();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) async {
        if (state.sucess != null &&
            state.message?.isNotEmpty == true &&
            state.message != null) {
          if (state.sucess == true) {
            await showMessageSnackBar(
              context,  
              title: state.message!,
              type: MessageType.success,
            );
            if (!context.mounted) return;
            AppRouter.goNamedByPath(context, NameRoutes.main);
          }
          if (state.sucess == false) {
            if (!context.mounted) return;
            await showMessageSnackBar(
              context,
              title: state.message!,
              type: MessageType.error,
            );
          }
        }
      },
      child: Form(
        key: _key,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppCustomtext(
              text: AppStrings.welcome,
              textStyle: AppTextStyles.h5SemiBold,
            ),
            SizedBox(height: 8.h),
            AppCustomtext(
              text: AppStrings.welcomeHint,
              textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: 40.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Column(
                children: [
                  AppTextField(
                    controller: _emailController,
                    validator: (p0) => SahihValidator.email(email: p0 ?? ""),
                    keyboard: TextInputType.emailAddress,
                    hint: AppStrings.email,
                  ),
                  CustomPasswordTextFromField(
                    controller: _passwordController,
                    fieldId: 'Password_1#',
                    hintText: AppStrings.password,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: AppCustomtext(
                        text: AppStrings.forgotPassword,
                        textStyle: AppTextStyles.bodySmallSemiBold.copyWith(
                          color: AppColors.colorPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  BuildButtonApp(
                    actions: () async {
                      if (_key.currentState?.validate() == true) {
                        await showMessageSnackBar(
                          context,
                          title: "loading ${AppStrings.login}",
                          type: MessageType.loading,
                          onLoading: () async => await context
                              .read<AuthenticationCubit>()
                              .loginByEmail(),
                        );
                      }
                    },
                    text: AppStrings.login,
                  ),
                  SizedBox(height: 20.h),
                  AppCustomtext(
                    text: AppStrings.orContinue,
                    textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  BuildButtonAppWithIcon(
                    actions: () async => await showMessageSnackBar(
                      context,
                      title: "loading ${AppStrings.orSignInWithGoogle}",
                      type: MessageType.loading,
                      onLoading: () async => await context
                          .read<AuthenticationCubit>()
                          .loginByGoogle(),
                    ),
                    iconErrorBuilder:AppIcons.google,
                    text: AppStrings.orSignInWithGoogle,
                    textIcon: "",
                  ),
                  SizedBox(height: 16.h),
                  BuildButtonAppWithIcon(
                    actions: () async => await showMessageSnackBar(
                      context,
                      title: "loading ${AppStrings.orSignInWithFacebook}",
                      type: MessageType.loading,
                      onLoading: () async => await context
                          .read<AuthenticationCubit>()
                          .loginByfacebook(),
                    ),
                    iconErrorBuilder: AppIcons.facebook,
                    text: AppStrings.orSignInWithFacebook,
                    textIcon: "",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
