import 'dart:math';

/// Generates a cryptographically secure random string of [length].
/// Uses an unambiguous uppercase alphanumeric alphabet (A-Z, 2-9),
/// excluding characters like 0/O and 1/I to reduce confusion.
String generateSecureCode(int length) {
  const String alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final Random rng = Random.secure();

  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < length; i++) {
    final int index = rng.nextInt(alphabet.length);
    buffer.write(alphabet[index]);
  }
  return buffer.toString();
}

/// Convenience helpers for subject-specific identifiers
String generateSubjectId([int length = 20]) => generateSecureCode(length);
String generateExamId([int length = 30]) => generateSecureCode(length);
String generateSubjectJoinCode([int length = 5]) => generateSecureCode(length);
