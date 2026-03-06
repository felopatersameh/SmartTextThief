import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smart_text_thief/Config/Routes/Routes/about_route.dart';
import 'package:smart_text_thief/Config/Routes/Routes/help_route.dart';
import 'package:smart_text_thief/Config/Routes/Routes/login_route.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/cubit/subjects_cubit.dart';
import '../../../../Config/app_config.dart';
import '../../../Notifications/Presentation/cubit/notifications_cubit.dart';
import '../../../login/Data/authentication_source.dart';
import '../../../../Core/LocalStorage/get_local_storage.dart';
import '../../../../Core/LocalStorage/local_storage_service.dart';
import '/Core/Utils/show_message_snack_bar.dart';

import '../../../../Config/Routes/name_routes.dart';
import '../../../../Core/Resources/resources.dart';
import '../../../../Core/Utils/Widget/custom_text_app.dart';
import '../Widgets/info_card.dart';
import '../Widgets/option_tile.dart';
import '../Widgets/profile_avatar.dart';
import '../cubit/profile_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(NameRoutes.profile.titleAppBar)),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
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
                              title: option.value,
                              subtitle: option.name,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AppCustomText.generate(
                          text: ProfileStrings.manageAccount,
                          textStyle: AppTextStyles.h7Medium.copyWith(
                            color: AppColors.white70,
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
                        title: ProfileStrings.about,
                        onTap: () async => AboutRoute.push(
                          context,
                          email: GetLocalStorage.getEmailUser(),
                        ),
                      ),
                      OptionTile(
                        title: ProfileStrings.help,
                        onTap: () async => HelpRoute.push(
                          context,
                          email: GetLocalStorage.getEmailUser(),
                        ),
                      ),
                      // OptionTile(
                      //   title: ProfileStrings.deleteAccount,
                      //   color: AppColors.danger.withValues(alpha: .45),
                      //   onTap: () async {
                      //     final isConfirm = await _showDeleteAccountDialog(
                      //       context,
                      //     );
                      //     if (isConfirm != true || !context.mounted) return;

                      //     bool isDeleted = false;
                      //     await showMessageSnackBar(
                      //       context,
                      //       title: ProfileStrings.deletingAccount,
                      //       type: MessageType.loading,
                      //       onLoading: () async {
                      //         isDeleted = await context
                      //             .read<ProfileCubit>()
                      //             .deleteCurrentUserData();
                      //         if (!isDeleted || !context.mounted) return;

                      //         await context.read<NotificationsCubit>().clear(
                      //               keepAllUsers: true,
                      //             );
                      //         await AuthenticationSource.logout();
                      //         await LocalStorageService.clear();
                      //         if (!context.mounted) return;
                      //         LoginRoute.push(context);
                      //       },
                      //     );

                      //     if (!isDeleted && context.mounted) {
                      //       await showMessageSnackBar(
                      //         context,
                      //         title: ProfileStrings.failedToDeleteAccount,
                      //         type: MessageType.error,
                      //       );
                      //     }
                      //   },
                      // ),
                      OptionTile(
                        title: ProfileStrings.logout,
                        color: AppColors.dangerAccent.withValues(alpha: .3),
                        onTap: () async {
                          await showMessageSnackBar(
                            context,
                            title: ProfileStrings.waiting,
                            type: MessageType.loading,
                            onLoading: () async {
                              await AuthenticationSource.logout();
                              await LocalStorageService.clear();
                              if (!context.mounted) return;
                              await context.read<NotificationsCubit>().clear();
                              if (!context.mounted) return;
                              await context.read<SubjectCubit>().logOut();
                              if (!context.mounted) return;
                              LoginRoute.push(context);
                            },
                          );
                        },
                      ),
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: AppCustomText.generate(
                                text: ProfileStrings.appVersionPatch,
                                textStyle:
                                    AppTextStyles.bodySmallMedium.copyWith(
                                  color: AppColors.white54,
                                ),
                              ),
                            );
                          }
                          final info = snapshot.data!;
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppCustomText.generate(
                                  text: info.appName,
                                  textStyle:
                                      AppTextStyles.bodySmallMedium.copyWith(
                                    color: AppColors.white60,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                AppCustomText.generate(
                                  text:
                                      'Version ${info.version}+${info.buildNumber}',
                                  textStyle:
                                      AppTextStyles.bodySmallMedium.copyWith(
                                    color: AppColors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
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

  // Future<bool?> _showDeleteAccountDialog(BuildContext context) {
  //   return AppDialogService.showConfirmDialog(
  //     context,
  //     title: ProfileStrings.deleteAccount,
  //     message: ProfileStrings.deleteAccountConfirm,
  //     confirmText: AppStrings.delete,
  //     destructive: true,
  //   );
  // }
}
