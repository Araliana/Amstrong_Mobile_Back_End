import 'package:bcrypt/bcrypt.dart';
import 'package:intl/intl.dart';

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

String formatDateTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }
}

String formatDate(DateTime dateTime) {
  return DateFormat('dd MMM yyyy').format(dateTime);
}
