import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../Subjects/cubit/subjects_cubit.dart';
import '../../Profile/cubit/profile_cubit.dart';
import '../Data/authentication_source.dart';
part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationState());

  Future<void> loginByEmail() async {
    emit(state.copyWith(loading: true, message: "", sucess: null));
    await Future.delayed(Duration(seconds: 2));
    emit(
      state.copyWith(message: "sucssed Login ", sucess: true, loading: false),
    );
  }

  Future<void> loginByGoogle(BuildContext context) async {
    emit(state.copyWith(loading: true, message: "", sucess: null));
    final response = await AuthenticationSource.loginWithGoogle();
    response.fold(
      (err) => emit(
        state.copyWith(message: err.message, sucess: false, loading: false),
      ),
      (su) async {
        await getDataWhenLogin(context);
        emit(
          state.copyWith(
            message: "sucssed Login By Google",
            sucess: su,
            loading: false,
          ),
        );
      },
    );
  }

  Future<void> loginByfacebook() async {
    emit(state.copyWith(loading: true, message: "", sucess: null));
    await Future.delayed(Duration(seconds: 2));
    emit(
      state.copyWith(
        message: "sucssed Login By Facebook",
        sucess: true,
        loading: false,
      ),
    );
  }

  Future<void> getDataWhenLogin(BuildContext context) async {
    final user = await context.read<ProfileCubit>().init();
    if (!context.mounted) return;
    await context.read<SubjectCubit>().init(user.userEmail, user.isStu);
  }
}
