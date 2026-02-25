
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Core/Services/Notifications/notification_services.dart';
import 'package:smart_text_thief/Features/Notifications/Presentation/cubit/notifications_cubit.dart';

import '../../../../Core/Utils/Models/subject_model.dart';
import '../../../Profile/Persentation/cubit/profile_cubit.dart';
import '../../../Subjects/Persentation/cubit/subjects_cubit.dart';
import '../../../../Core/Utils/Enums/enum_user.dart';
import '../../Data/authentication_source.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationState());

  Future<void> loginByGoogle(BuildContext context) async {
    emit(
      state.copyWith(
        loading: true,
        message: "",
        success: null,
        requireRoleSelection: false,
      ),
    );
    final response = await AuthenticationSource.loginWithGoogle();
    response.fold(
      (err) => emit(
        state.copyWith(
          message: err.message,
          success: false,
          loading: false,
          requireRoleSelection: false,
        ),
      ),
      (su) async {
        final requireRoleSelection = await getDataWhenLogin(context);
        emit(
          state.copyWith(
            message: "success Login By Google",
            success: su,
            loading: false,
            requireRoleSelection: requireRoleSelection,
          ),
        );
      },
    );
  }

  Future<bool> getDataWhenLogin(BuildContext context) async {
    final user = await context.read<ProfileCubit>().init();
    // if (!context.mounted) return false;
    // await context.read<NotificationsCubit>().init();

    if (user.userType == UserType.non) {
      return true;
    }
    if (!context.mounted) return false;
    final result = await Future.wait([
      context.read<SubjectCubit>().init(),
      context.read<NotificationsCubit>().init(),
    ]);
    final subjects = result[0] as List<SubjectModel>;
    for (var element in subjects) {
      await NotificationServices.subscribeToTopic(element.topicID);
    }
    return false;
  }
}
