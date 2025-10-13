import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

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

  Future<void> loginByGoogle() async {
    emit(state.copyWith(loading: true, message: "", sucess: null));
    final response = await AuthenticationSource.loginWithGoogle();
    response.fold(
      (err) => emit(
          state.copyWith(message: err.message, sucess: false, loading: false),
        ),
      (su) => emit(
          state.copyWith(
            message: "sucssed Login By Google",
            sucess: su,
            loading: false,
          ),
        ),
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
}
