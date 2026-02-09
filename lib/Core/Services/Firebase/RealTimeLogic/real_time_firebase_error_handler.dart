class RealtimeFirebaseErrorHandler {
  const RealtimeFirebaseErrorHandler._();

  static Never throwNotInitialized() {
    throw Exception(
      'RealtimeFirebase not initialized. Call RealtimeFirebase.initialize() first.',
    );
  }

  static Never throwOperationError(String operation, Object error) {
    throw Exception('$operation failed: $error');
  }
}
