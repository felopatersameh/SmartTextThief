import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../Core/Utils/Enums/enum_user.dart';
import '../../../../Core/Utils/Models/data_model.dart';
import '../../Data/profile_source.dart';
import '/Core/Utils/Models/user_model.dart';

part 'profile_state.dart';
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState());

  Future<UserModel> init() async {
    emit(state.copyWith(loading: true, options: [], model: UserModel.empty()));
    final response = await ProfileSource.getDataUser();
    response.fold(
      (error) => emit(
        state.copyWith(loading: false, options: [], model: UserModel.empty()),
      ),
      (tuple) => emit(
        state.copyWith(model: tuple.$1, options: tuple.$2, loading: false),
      ),
    );
    return state.model ?? UserModel.empty();
  }

  Future<bool> updateType(UserType userType) async {
    bool result = false;
    final response = await ProfileSource.updateType(userType.value);
    response.fold(
      (ifLeft) {
        result = false;
      },
      (ifRight) {
        result = ifRight;
      },
    );
    return result;
  }

  Future<bool> updateGeminiApiKey(String geminiApiKey) async {
    bool result = false;
    final response = await ProfileSource.updateGeminiApiKey(geminiApiKey);
    response.fold(
      (ifLeft) {
        result = false;
      },
      (ifRight) {
        result = ifRight;
      },
    );

    if (result && state.model != null) {
      emit(
        state.copyWith(
          model: state.model!.copyWith(userGeminiApiKey: geminiApiKey),
        ),
      );
    }
    return result;
  }

  Future<bool> deleteCurrentUserData() async {
    bool result = false;
    final response = await ProfileSource.deleteCurrentUserData();
    response.fold(
      (ifLeft) {
        result = false;
      },
      (ifRight) {
        result = ifRight;
      },
    );
    return result;
  }
}
