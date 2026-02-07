import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Notifications/Persentation/cubit/notifications_cubit.dart';
import '../../../Profile/Persentation/cubit/profile_cubit.dart';
import '../../../Subjects/Persentation/cubit/subjects_cubit.dart';
import '../../Data/authentication_source.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationState());

  Future<void> loginByEmail() async {
    emit(state.copyWith(loading: true, message: "", success: null));
    await Future.delayed(Duration(seconds: 2));
    emit(
      state.copyWith(message: "success Login ", success: true, loading: false),
    );
  }

  Future<void> loginByGoogle(BuildContext context) async {
    emit(state.copyWith(loading: true, message: "", success: null));
    final response = await AuthenticationSource.loginWithGoogle();
    response.fold(
      (err) => emit(
        state.copyWith(message: err.message, success: false, loading: false),
      ),
      (su) async {
        await getDataWhenLogin(context);
        emit(
          state.copyWith(
            message: "success Login By Google",
            success: su,
            loading: false,
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

  Future<void> getDataWhenLogin(BuildContext context) async {
    final user = await context.read<ProfileCubit>().init();
    if (!context.mounted) return;
    await Future.wait([
      context.read<SubjectCubit>().init(user.userEmail, user.isStu),
      context.read<NotificationsCubit>().init(user.subscribedTopics),
    ]);
  }

    @override
  Future<void> close() {
    emit(AuthenticationState());
    return super.close();
  }
}
