import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Core/Utils/Enums/data_key.dart';
import 'package:smart_text_thief/Core/Utils/Enums/enum_user.dart';
import '/Core/Storage/Local/local_storage_keys.dart';
import '/Core/Storage/Local/local_storage_service.dart';
import '/Core/Utils/Enums/collection_key.dart';
import '/Core/Utils/Models/user_model.dart';

import '../../../Core/Services/Firebase/firebase_service.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState());
  Future<UserModel> init() async {
    emit(state.copyWith(loading: true, options: []));

    final String userId = await LocalStorageService.getValue(
      LocalStorageKeys.id,
    );
    final response = await FirebaseServices.instance.getData(
      userId,
      CollectionKey.users.key,
    );
    final Map<String, dynamic> data = response.data;
    final model = UserModel.fromJson(data);
    emit(state.copyWith(model: model));
    final options = await analyzedData();
    emit(state.copyWith(loading: false, options: options));
    return model;
  }

  Future<bool> updateType(UserType userType) async {
    final String userId = await LocalStorageService.getValue(
      LocalStorageKeys.id,
    );
    final response = await FirebaseServices.instance.updateData(
      CollectionKey.users.key,
      userId,
      {DataKey.userType.key: userType.value},
    );
    if (!response.status) return false;
    return true;
  }

  Future<List<DataModel>> analyzedData() async {
    final bool check = state.model?.isTe ?? false;
    if (check) {
      return await analyzedInstructor();
    } else {
      return await analyzedStudent();
    }
  }

  Future<List<DataModel>> analyzedStudent() async {
    List<DataModel> list = [];
    final emailUser = state.model?.userEmail ?? "";
    if (emailUser.isNotEmpty) {
      list = await FirebaseServices.instance.analyzedStudent(email: emailUser);
    }
    return list;
  }

  Future<List<DataModel>> analyzedInstructor() async {
    List<DataModel> list = [];
    final emailUser = state.model?.userEmail ?? "";
    if (emailUser.isNotEmpty) {
      list = await FirebaseServices.instance.analyzedInstructor(
        email: emailUser,
      );
    }
    return list;
  }
}

class DataModel {
  final String name;
  final num _valueNum;
  final String _valueString;
  DataModel({
    required this.name,
    required num valueNum,
    String valueString = "none",
  }) : _valueString = valueString,
       _valueNum = valueNum;

  String get value => (_valueNum == -1) ? _valueString : _valueNum.toString();
}
