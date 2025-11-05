import 'dart:convert';
import 'dart:io';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/access.dart';
import 'package:flutter_application_1/provider/admin_provider.dart';
import 'package:flutter_application_1/provider/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

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

Future<Map<String, List<Access>>> groupAccessesByCategory(
  BuildContext context,
) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final adminProvider = Provider.of<AdminProvider>(context, listen: false);

  final userID = authProvider.currUserId;
  if (userID == null) {
    return {}; // Return empty map if no username
  }

  final currUser = await adminProvider.getCurrUser(userID);
  final Map<String, List<Access>> grouped = {};

  // Check if user has role and access
  if (currUser.role?.access != null) {
    for (var access in currUser.role!.access!) {
      if (!grouped.containsKey(access.category)) {
        grouped[access.category] = [];
      }
      grouped[access.category]!.add(access);
    }
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

final String privateKey = "private_jcw73bL0uzySjVOBzHIMUYc0cag=";
final String uploadEndpoint = "https://upload.imagekit.io/api/v1/files/upload";

Future<String> uploadFile(File file, {String? folder}) async {
  final uri = Uri.parse(uploadEndpoint);
  final request = http.MultipartRequest('POST', uri);

  final String basicAuth = 'Basic ${base64Encode(utf8.encode('$privateKey:'))}';
  request.headers['Authorization'] = basicAuth;

  request.files.add(await http.MultipartFile.fromPath('file', file.path));
  request.fields['fileName'] = file.uri.pathSegments.last;

  if (folder != null && folder.isNotEmpty) {
    final cleanFolder = folder.replaceAll(RegExp(r'^/+|/+$'), '');
    request.fields['folder'] = 'KJM/$cleanFolder';
  } else {
    request.fields['folder'] = 'KJM';
  }

  final response = await request.send();
  final respStr = await response.stream.bytesToString();

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(respStr);
    return data['url'] as String;
  } else {
    throw Exception('ImageKit upload failed: $respStr');
  }
}
