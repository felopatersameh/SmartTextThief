part of 'authentication_cubit.dart';

@immutable
class AuthenticationState extends Equatable {
  final bool? loading;
  final String? message;
  final bool? success;
  final bool requireRoleSelection;
  const AuthenticationState({
    this.loading,
    this.message,
    this.success,
    this.requireRoleSelection = false,
  });

  AuthenticationState copyWith(
      {bool? loading,
      String? message,
      bool? success,
      bool? requireRoleSelection}) {
    return AuthenticationState(
      loading: loading ?? this.loading,
      message: message ?? this.message,
      success: success ?? this.success,
      requireRoleSelection:
          requireRoleSelection ?? this.requireRoleSelection,
    );
  }

  @override
  List<Object?> get props => [loading, message, success, requireRoleSelection];
}
