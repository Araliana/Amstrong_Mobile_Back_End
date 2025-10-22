import 'dart:io';
import 'package:bcrypt/bcrypt.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/access.dart';
import 'package:flutter_application_1/provider/access_provider.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

final List<String> accessCategory = [
  'ORDERS',
  'PRODUCTS & STOCK',
  'FINANCE',
  'CONTENT & MEDIA',
  'MANAGEMENT',
];

List<MapEntry<String, List<Access>>> sortAccess(
  Map<String, List<Access>> data,
) {
  final sortedEntries = data.entries.toList()
    ..sort((a, b) {
      final ai = accessCategory.indexOf(a.key);
      final bi = accessCategory.indexOf(b.key);
      if (ai == -1 && bi == -1) return a.key.compareTo(b.key);
      if (ai == -1) return 1;
      if (bi == -1) return -1;
      return ai.compareTo(bi);
    });
  return sortedEntries;
}

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

Future<String?> uploadFile(File file) async {
  try {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ext = p.extension(file.path); // contoh: .jpg / .png / .pdf

    final ref = FirebaseStorage.instance.ref().child(
      'images/$fileName$ext',
    ); // pakai ext asli

    await ref.putFile(file);
    return await ref.getDownloadURL();
  } catch (e) {
    print("Error: $e");
    return null;
  }
}

Future<Map<String, List<Access>>> groupAccessesByCategory(
  BuildContext context,
) async {
  final accessProvider = Provider.of<AccessProvider>(context, listen: false);
  await accessProvider.loadAccess();
  final Map<String, List<Access>> grouped = {};
  for (var access in accessProvider.accesses) {
    if (!grouped.containsKey(access.category)) {
      grouped[access.category] = [];
    }
    grouped[access.category]!.add(access);
  }
  return grouped;
}

Color getCategoryColor(String category) {
  switch (category) {
    case "ORDERS":
      return Colors.indigo;
    case "PRODUCTS & STOCK":
      return Colors.deepPurple;
    case "FINANCE":
      return Colors.amber;
    case "CONTENT & MEDIA":
      return Colors.teal;
    case "MANAGEMENT":
      return Colors.brown;
    default:
      return Colors.grey;
  }
}
