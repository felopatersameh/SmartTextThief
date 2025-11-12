import 'package:equatable/equatable.dart';
import '../Enums/enum_user.dart';
import '../Enums/data_key.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.userId,
    required this.photo,
    required this.userTokensFcm,
    required this.userName,
    required this.userEmail,
    required this.userPassword,
    required this.userPhone,
    required this.userType,
    required this.userCreatedAt,
    this.subscribedTopics = const [],
  });

  final String userId;
  final List<String> userTokensFcm;
  final String photo;
  final String userName;
  final String userEmail;
  final String userPassword;
  final String userPhone;
  final UserType userType;
  final DateTime userCreatedAt;
  final List<String> subscribedTopics;

  UserModel copyWith({
    String? userId,
    List<String>? userTokensFcm,
    String? userName,
    String? userEmail,
    String? userPassword,
    String? userPhone,
    String? photo,
    UserType? userType,
    DateTime? userCreatedAt,
    List<String>? subscribedTopics,
    List<dynamic>? userNotifications,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      userTokensFcm: userTokensFcm ?? this.userTokensFcm,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPassword: userPassword ?? this.userPassword,
      userPhone: userPhone ?? this.userPhone,
      photo: photo ?? this.photo,
      userType: userType ?? this.userType,
      userCreatedAt: userCreatedAt ?? this.userCreatedAt,
      subscribedTopics: subscribedTopics ?? this.subscribedTopics,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json[DataKey.userId.key] ?? "",
      userTokensFcm: json[DataKey.userTokensFCM.key] == null
          ? []
          : List<String>.from(json[DataKey.userTokensFCM.key]!.map((x) => x)),
      userName: json[DataKey.userName.key] ?? "",
      photo: json[DataKey.photo.key] ?? "",
      userEmail: json[DataKey.userEmail.key] ?? "",
      userPassword: json[DataKey.userPassword.key] ?? "",
      userPhone: json[DataKey.userPhone.key] ?? "",
      userType: UserType.fromString(json[DataKey.userType.key] ?? "non"),
      userCreatedAt: json[DataKey.userCreatedAt.key] is String
          ? DateTime.tryParse(json[DataKey.userCreatedAt.key]) ?? DateTime.now()
          : (json[DataKey.userCreatedAt.key] is DateTime
                ? json[DataKey.userCreatedAt.key]
                : DateTime.now()),
      subscribedTopics: json[DataKey.subscribedTopics.key] == null
          ? []
          : List<String>.from(json[DataKey.subscribedTopics.key].map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
    DataKey.userId.key: userId,
    DataKey.userTokensFCM.key: userTokensFcm.map((x) => x).toList(),
    DataKey.userName.key: userName,
    DataKey.userEmail.key: userEmail,
    DataKey.userPassword.key: userPassword,
    DataKey.photo.key: photo,
    DataKey.userPhone.key: userPhone,
    DataKey.userType.key: userType.value,
    DataKey.userCreatedAt.key: userCreatedAt,
    DataKey.subscribedTopics.key: subscribedTopics.map((x) => x).toList(),
  };

  bool get isStu => userType.value == UserType.st.value;
  bool get isTe => userType.value == UserType.te.value;
  @override
  List<Object?> get props => [
    userId,
    userTokensFcm,
    userName,
    userEmail,
    photo,
    userPassword,
    userPhone,
    userType.value,
    userCreatedAt,
    subscribedTopics,
  ];
}
