import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Notifications/Persentation/cubit/notifications_cubit.dart';
import '../../../Profile/Persentation/cubit/profile_cubit.dart';
import '../../../Subjects/Persentation/cubit/subjects_cubit.dart';
import '../../../../Core/Utils/Enums/enum_user.dart';
import '../../Data/authentication_source.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationState());

  Future<void> loginByEmail() async {
    emit(
      state.copyWith(
        loading: true,
        message: "",
        success: null,
        requireRoleSelection: false,
      ),
    );
    await Future.delayed(Duration(seconds: 2));
    emit(
      state.copyWith(
        message: "success Login ",
        success: true,
        loading: false,
        requireRoleSelection: false,
      ),
    );
  }

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

  Future<void> loginByFacebook() async {
    // emit(state.copyWith(loading: true, message: "", success: null));
    // await Future.delayed(Duration(seconds: 2));
    // emit(
    //   state.copyWith(
    //     message: "success Login By Facebook",
    //     success: true,
    //     loading: false,
    //   ),
    // );
  }

  Future<bool> getDataWhenLogin(BuildContext context) async {
    final user = await context.read<ProfileCubit>().init();
    if (!context.mounted) return false;
    await context.read<NotificationsCubit>().init(user.subscribedTopics);

    if (user.userType == UserType.non) {
      return true;
    }
    if (!context.mounted) return false;

    await context.read<SubjectCubit>().init(user.userEmail, user.isStu);
    return false;
  }

  @override
  Future<void> close() {
    emit(AuthenticationState());
    return super.close();
  }
}
