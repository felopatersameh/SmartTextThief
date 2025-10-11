part of 'authentication_cubit.dart';

@immutable
class AuthenticationState extends Equatable {
  final bool ? loading;
  final String? message;
  final bool? sucess;
  const AuthenticationState({this.loading , this.message, this.sucess});

  AuthenticationState copyWith({bool? loading, String? message, bool? sucess}) {
    return AuthenticationState(
      loading: loading ?? this.loading,
      message: message ?? this.message,
      sucess: sucess ?? this.sucess,
    );
  }

  @override
  List<Object?> get props => [loading, message, sucess];
}
