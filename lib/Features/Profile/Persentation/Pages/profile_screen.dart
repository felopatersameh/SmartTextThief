import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../Config/app_config.dart';
import '../../../Notifications/Persentation/cubit/notifications_cubit.dart';
import '../../../../Core/LocalStorage/get_local_storage.dart';
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
                        title: 'Gemini API Key',
                        onTap: () async => await _showGeminiApiKeyDialog(
                          context,
                          state.model?.userGeminiApiKey ?? "",
                        ),
                      ),
                      OptionTile(
                        title: 'About',
                        onTap: () async => AppRouter.nextScreenNoPath(
                          context,
                          NameRoutes.about,
                          pathParameters: {
                            "email":
                                GetLocalStorage.getEmailUser().split("@").first,
                          },
                        ),
                      ),
                      OptionTile(
                        title: 'Help',
                        onTap: () async => AppRouter.nextScreenNoPath(
                          context,
                          NameRoutes.help,
                          pathParameters: {
                            "email":
                                GetLocalStorage.getEmailUser().split("@").first,
                          },
                        ),
                      ),
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
                                context,
                                NameRoutes.login,
                              );
                            },
                          );
                        },
                      ),
                      OptionTile(
                        title: 'Delete Account',
                        color: Colors.red.withValues(alpha: .45),
                        onTap: () async {
                          final isConfirm = await _showDeleteAccountDialog(
                            context,
                          );
                          if (isConfirm != true || !context.mounted) return;

                          bool isDeleted = false;
                          await showMessageSnackBar(
                            context,
                            title: "Deleting account...",
                            type: MessageType.loading,
                            onLoading: () async {
                              isDeleted = await context
                                  .read<ProfileCubit>()
                                  .deleteCurrentUserData();
                              if (!isDeleted || !context.mounted) return;

                              await context.read<NotificationsCubit>().clear(
                                    keepAllUsers: true,
                                  );
                              await LocalStorageService.clear();
                              await FirebaseServices.instance.logOut();
                              if (!context.mounted) return;
                              AppRouter.goNamedByPath(context, NameRoutes.login);
                            },
                          );

                          if (!isDeleted && context.mounted) {
                            await showMessageSnackBar(
                              context,
                              title: "Failed to delete account",
                              type: MessageType.error,
                            );
                          }
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

  Future<void> _showGeminiApiKeyDialog(
    BuildContext context,
    String currentApiKey,
  ) async {
    final String? apiKey = await showDialog<String>(
      context: context,
      builder: (_) => _GeminiApiKeyDialog(initialValue: currentApiKey),
    );

    if (apiKey == null || !context.mounted) return;

    bool updated = false;
    await showMessageSnackBar(
      context,
      title: "Saving Gemini API key...",
      type: MessageType.loading,
      onLoading: () async {
        updated = await context.read<ProfileCubit>().updateGeminiApiKey(apiKey);
      },
    );
    if (!context.mounted) return;

    await showMessageSnackBar(
      context,
      title: updated ? "Gemini API key updated" : "Failed to update API key",
      type: updated ? MessageType.success : MessageType.error,
    );
  }

  Future<bool?> _showDeleteAccountDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.colorsBackGround2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(
            color: AppColors.colorPrimary.withValues(alpha: 0.3),
          ),
        ),
        title: AppCustomText.generate(
          text: 'Delete Account',
          textStyle: AppTextStyles.h6Bold.copyWith(color: Colors.redAccent),
        ),
        content: AppCustomText.generate(
          text: 'This will permanently delete your account data. Continue?',
          textStyle: AppTextStyles.bodyMediumMedium.copyWith(
            color: AppColors.textCoolGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: AppCustomText.generate(
              text: 'Cancel',
              textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
                color: AppColors.textWhite,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: AppCustomText.generate(
              text: 'Delete',
              textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeminiApiKeyDialog extends StatefulWidget {
  const _GeminiApiKeyDialog({required this.initialValue});

  final String initialValue;

  @override
  State<_GeminiApiKeyDialog> createState() => _GeminiApiKeyDialogState();
}

class _GeminiApiKeyDialogState extends State<_GeminiApiKeyDialog> {
  late final TextEditingController _controller;
  bool _isHidden = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.colorsBackGround2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: AppColors.colorPrimary.withValues(alpha: 0.3),
        ),
      ),
      title: AppCustomText.generate(
        text: 'Gemini API Key',
        textStyle: AppTextStyles.h6Bold.copyWith(
          color: AppColors.textWhite,
        ),
      ),
      content: TextFormField(
        controller: _controller,
        obscureText: _isHidden,
        keyboardType: TextInputType.visiblePassword,
        style: AppTextStyles.bodyMediumMedium.copyWith(
          color: AppColors.textWhite,
        ),
        decoration: InputDecoration(
          hintText: 'Enter your Gemini API key',
          hintStyle: AppTextStyles.bodyMediumMedium.copyWith(
            color: Colors.white54,
          ),
          fillColor: AppColors.colorTextFieldBackGround,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() => _isHidden = !_isHidden);
            },
            icon: Icon(
              _isHidden ? Icons.visibility : Icons.visibility_off,
              color: Colors.white70,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: AppCustomText.generate(
            text: 'Cancel',
            textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
              color: AppColors.textWhite,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: AppCustomText.generate(
            text: 'Save',
            textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
              color: AppColors.colorPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
