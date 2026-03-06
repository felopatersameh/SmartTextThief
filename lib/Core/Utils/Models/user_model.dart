import 'package:equatable/equatable.dart';
import '../Enums/enum_user.dart';
import '../Enums/data_key.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.photo,
    required this.userName,
    required this.userEmail,
    required this.userType,
  });

  final String photo;
  final String userName;
  final String userEmail;
  final UserType userType;

  factory UserModel.empty() {
    return UserModel(
      userName: '',
      userEmail: '',
      photo: '',
      userType: UserType.non,
    );
  }

  UserModel copyWith({
    String? userName,
    String? userEmail,
    String? photo,
    UserType? userType,
  }) {
    return UserModel(
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      photo: photo ?? this.photo,
      userType: userType ?? this.userType,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userName: (json[DataKey.name.key]).toString(),
      photo: (json[DataKey.photo.key]).toString(),
      userEmail: (json[DataKey.email.key]).toString(),
      userType: UserType.fromString((json[DataKey.role.key]).toString()),
    );
  }

  bool get isStu => userType.value == UserType.st.value;
  bool get isTe => userType.value == UserType.te.value;

  @override
  List<Object?> get props => [
        userName,
        userEmail,
        photo,
        userType.value,
      ];
}
