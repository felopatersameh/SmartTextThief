part of 'profile_cubit.dart';

class ProfileState extends Equatable {
  final UserModel? model;
  final bool? loading;
  final List<DataModel>? options;
  const ProfileState({this.model, this.loading, this.options = const []});

  @override
  List<Object?> get props => [model, loading, options];

  ProfileState copyWith({
    UserModel? model,
    bool? loading,
    List<DataModel>? options,
  }) {
    return ProfileState(
      model: model ?? this.model,
      loading: loading ?? this.loading,
      options: options ?? this.options,
    );
  }
}
