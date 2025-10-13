part of 'profile_cubit.dart';

class ProfileState extends Equatable {
  final UserModel? model;
  final bool? loading;
  const ProfileState({this.model, this.loading});

  @override
  List<Object> get props => [?model, ?loading];

  ProfileState copyWith({UserModel? model, bool? loading}) {
    return ProfileState(
      model: model ?? this.model,
      loading: loading ?? this.loading,
    );
  }
}
