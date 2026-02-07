part of 'authentication_cubit.dart';

@immutable
class AuthenticationState extends Equatable {
  final bool? loading;
  final String? message;
  final bool? success;
  const AuthenticationState({this.loading, this.message, this.success});

  AuthenticationState copyWith(
      {bool? loading, String? message, bool? success}) {
    return AuthenticationState(
      loading: loading ?? this.loading,
      message: message ?? this.message,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [loading, message, success];
}
