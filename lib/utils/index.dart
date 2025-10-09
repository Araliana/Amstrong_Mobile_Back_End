import 'package:bcrypt/bcrypt.dart';

T enumFromString<T extends Enum>(Iterable<T> values, String value) {
  return values.firstWhere(
    (e) => e.name == value,
    orElse: () => throw ArgumentError('No enum value "$value" found in $T'),
  );
}

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

String hashPassword(String password) {
  final salt = BCrypt.gensalt();
  return BCrypt.hashpw(password, salt);
}

bool verifyPassword(String password, String hashedPassword) {
  return BCrypt.checkpw(password, hashedPassword);
}
