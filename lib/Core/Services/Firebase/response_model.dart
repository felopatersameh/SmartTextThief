import 'failure_model.dart';

class ResponseModel {
  final String message;
  final bool status;
  final dynamic data;
  final FailureModel? failure;

  ResponseModel({
    required this.message,
    required this.status,
    this.data,
    this.failure,
  });

  factory ResponseModel.success({String message = 'Success', dynamic data}) {
    return ResponseModel(message: message, status: true, data: data);
  }

  factory ResponseModel.error(
      {String message = 'Error', dynamic data, FailureModel? failure}) {
    return ResponseModel(
        message: message, status: false, data: data, failure: failure);
  }

  @override
  String toString() {
    return 'ResponseModel{message: $message, status: $status, data: $data, failure: $failure}';
  }

  ResponseModel copyWith({
    String? message,
    bool? status,
    dynamic data,
    FailureModel? failure,
  }) {
    return ResponseModel(
      message: message ?? this.message,
      status: status ?? this.status,
      data: data ?? this.data,
      failure: failure ?? this.failure,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status': status,
      'data': data,
      'failure': failure?.toJson(),
    };
  }
}
