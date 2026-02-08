import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../Config/Routes/app_router.dart';
import '../../../Config/Routes/name_routes.dart';
import '../../../Core/Resources/resources.dart';
import '../../../Core/Utils/Enums/enum_user.dart';
import '../../../Core/Utils/Widget/ButtonsStyle/build_button_app.dart';
import '../../../Core/Utils/Widget/custom_text_app.dart';
import '../../../Core/Utils/show_message_snack_bar.dart';
import '../../Notifications/Persentation/cubit/notifications_cubit.dart';
import '../../Profile/Persentation/cubit/profile_cubit.dart';
import '../../Subjects/Persentation/cubit/subjects_cubit.dart';

class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({super.key});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  bool _loading = false;

  Future<void> _selectRole(UserType userType) async {
    if (_loading) return;
    setState(() => _loading = true);

    final isUpdated = await context.read<ProfileCubit>().updateType(userType);
    if (!mounted) return;

    if (!isUpdated) {
      setState(() => _loading = false);
      await showMessageSnackBar(
        context,
        title: 'Failed to save role, please try again',
        type: MessageType.error,
      );
      return;
    }

    final user = await context.read<ProfileCubit>().init();
    if (!mounted) return;

    await Future.wait([
      context.read<SubjectCubit>().init(user.userEmail, user.isStu),
      context.read<NotificationsCubit>().init(user.subscribedTopics),
    ]);
    if (!mounted) return;

    setState(() => _loading = false);
    AppRouter.goNamedByPath(context, NameRoutes.subject);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: AppCustomText.generate(
            text: 'Choose your role',
            textStyle: AppTextStyles.h6Bold,
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 420.w),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                  decoration: BoxDecoration(
                    color: AppColors.colorsBackGround2,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.colorPrimary.withValues(alpha: 0.25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          color: AppColors.colorPrimary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_user_outlined,
                          color: AppColors.colorPrimary,
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      AppCustomText.generate(
                        text: 'Select your role',
                        textStyle: AppTextStyles.h6Bold,
                      ),
                      SizedBox(height: 8.h),
                      AppCustomText.generate(
                        text: 'Choose how you want to use the app first.',
                        textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                          color: AppColors.textCoolGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      BuildButtonApp(
                        text: 'I am a Teacher',
                        background: AppColors.colorPrimary,
                        textStyle: AppTextStyles.bodyLargeSemiBold,
                        actions: () => _selectRole(UserType.te),
                      ),
                      SizedBox(height: 12.h),
                      BuildButtonApp(
                        text: 'I am a Student',
                        background: AppColors.colorTextFieldBackGround,
                        textStyle: AppTextStyles.bodyLargeSemiBold,
                        actions: () => _selectRole(UserType.st),
                      ),
                      SizedBox(height: 18.h),
                      if (_loading)
                        SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: AppColors.colorPrimary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
