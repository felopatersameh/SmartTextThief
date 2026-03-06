import 'package:equatable/equatable.dart';

class MessageResponseModel extends Equatable {
  const MessageResponseModel({
    required this.message,
  });

  final String message;

  factory MessageResponseModel.fromJson(Map<String, dynamic> json) {
    return MessageResponseModel(
      message: (json['message'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
      };

  @override
  List<Object?> get props => [message];
}

