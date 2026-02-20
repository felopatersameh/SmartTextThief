class ApiResponseModel<T> {
  final bool status;
  final String message;
  final T? data;
  
  const ApiResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) {
    return ApiResponseModel(
      status: (json['status'] as bool?) ?? true,
      message: (json['message'] ?? '').toString(),
      data: json.containsKey('data') ? fromJsonT(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return {
      'status': status,
      'message': message,
      if (data != null) 'data': toJsonT(data as T),
    };
  }
}
