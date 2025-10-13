class FailureModel {
  final String message;
  final dynamic error; 
  

  FailureModel({
    required this.message,
    this.error,
  });

  @override
  String toString() {
    return 'FailureModel{message: $message, error: $error}';
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'error': error,
    };
  }
}
