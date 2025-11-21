import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Config/app_config.dart';
import 'package:smart_text_thief/Features/Notifications/Persentation/cubit/notifications_cubit.dart';
import '../../../../Core/Utils/Enums/enum_user.dart';
import '/Core/Services/Firebase/firebase_service.dart';
import '../../../../Core/LocalStorage/local_storage_service.dart';
import '/Core/Utils/show_message_snack_bar.dart';

import '../../../../Config/Routes/app_router.dart';
import '../../../../Config/Routes/name_routes.dart';
import '../../../../Core/Resources/resources.dart';
import '../../../../Core/Utils/Widget/custom_text_app.dart';
import '../Widgets/info_card.dart';
import '../Widgets/option_tile.dart';
import '../Widgets/profile_avatar.dart';
import '../cubit/profile_cubit.dart';
import 'package:restart_app/restart_app.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(NameRoutes.profile.titleAppBar)),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final checkType = state.model!.userType == UserType.st;
          final typeConverting = checkType ? "Instructor" : "Student";
          if (state.loading == true) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: AppColors.colorPrimary,
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: CustomScrollView(
              physics: AppConfig.physicsCustomScrollView,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      ProfileAvatar(
                        name: state.model!.userName,
                        imageUrl: state.model!.photo,
                        email: state.model!.userEmail,
                        // isAdmin: true,
                      ),
                      SizedBox(height: 24.h),
                      Wrap(
                        runSpacing: 20.h,
                        spacing: 10.w,
                        children: [
                          ...(state.options ?? []).map(
                            (option) => InfoCard(
                                title: option.value, subtitle: option.name),
                          ),
                        ],
                      ),
                      SizedBox(height: 30.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AppCustomText.generate(
                          text: 'Manage Account',
                          textStyle: AppTextStyles.h7Medium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OptionTile(
                        title: 'Switch to $typeConverting',
                        onTap: () async {
                          await showMessageSnackBar(
                            context,
                            title: "Waiting Will Be Restarting....",
                            type: MessageType.loading,
                            onLoading: () async {
                              final userType =
                                  checkType ? UserType.te : UserType.st;
                              final isDone = await context
                                  .read<ProfileCubit>()
                                  .updateType(userType);
                              if (isDone) {
                                await Restart.restartApp();
                              }
                            },
                          );
                        },
                      ),
                      // OptionTile(title: 'Settings'),
                      OptionTile(title: 'About'),
                      OptionTile(title: 'Help'),
                      OptionTile(
                        title: 'logOut',
                        color: Colors.redAccent.withValues(alpha: .3),
                        onTap: () async {
                          await showMessageSnackBar(
                            context,
                            title: "Waiting...",
                            type: MessageType.loading,
                            onLoading: () async {
                              await LocalStorageService.clear();
                              await FirebaseServices.instance.logOut();
                              if (!context.mounted) return;
                              await context.read<NotificationsCubit>().clear();
                              if (!context.mounted) return;
                              AppRouter.goNamedByPath(
                                  context, NameRoutes.login);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
