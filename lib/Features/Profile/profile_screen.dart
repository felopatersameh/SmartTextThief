import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/Core/Services/Firebase/firebase_service.dart';
import '/Core/Storage/Local/local_storage_service.dart';
import '/Core/Utils/show_message_snack_bar.dart';

import '../../Config/Routes/app_router.dart';
import '../../Config/Routes/name_routes.dart';
import '../../Core/Resources/resources.dart';
import '../../Core/Utils/Widget/custom_text_app.dart';
import 'Widgets/info_card.dart';
import 'Widgets/option_tile.dart';
import 'Widgets/profile_avatar.dart';
import 'cubit/profile_cubit.dart';

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InfoCard(title: '12', subtitle: 'Exams Created'),
                    InfoCard(title: 'World History', subtitle: 'Last Exam'),
                  ],
                ),
                SizedBox(height: 45.h),
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
                OptionTile(title: 'Settings'),
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
                        AppRouter.goNamedByPath(context, NameRoutes.login);
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
