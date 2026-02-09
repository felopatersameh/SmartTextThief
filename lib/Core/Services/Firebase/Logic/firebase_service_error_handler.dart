import 'package:firebase_auth/firebase_auth.dart';

import '../failure_model.dart';
import '../response_model.dart';

class FirebaseServiceErrorHandler {
  const FirebaseServiceErrorHandler._();

  static ResponseModel authError(
    String message,
    FirebaseAuthException error,
  ) {
    return ResponseModel.error(
      message: message,
      failure: FailureModel(
        message: message,
        error: error,
      ),
    );
  }

  static ResponseModel operationError(
    String message,
    Object error,
  ) {
    return ResponseModel.error(
      message: message,
      failure: FailureModel(
        message: message,
        error: error,
      ),
    );
  }
}
