import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '/Core/Storage/Local/local_storage_keys.dart';
import '/Core/Storage/Local/local_storage_service.dart';
import '/Core/Utils/Enums/collection_key.dart';
import '/Core/Utils/Models/user_model.dart';

import '../../../Core/Services/Firebase/firebase_service.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState());
  Future<UserModel> init() async {
    emit(state.copyWith(loading: true));

    final String userId = await LocalStorageService.getValue(
      LocalStorageKeys.id,
    );
    final resonse = await FirebaseServices.instance.getData(
      userId,
      CollectionKey.users.key,
    );
    final Map<String, dynamic> data = resonse.data;
    final model = UserModel.fromJson(data);
    emit(state.copyWith(model: model, loading: false));
    return model;
  }
}
