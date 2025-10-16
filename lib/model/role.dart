import 'package:flutter_application_1/model/access.dart';

class Role {
  final int id;
  final String name;
  final List<Access>? access;

  Role({required this.id, required this.name, this.access});

  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      id: map['id'],
      name: map['name'],
      access: map['access'] == null
          ? null
          : (map['access'] as List)
                .map((e) => Access.fromMap((e as Map).cast<String, dynamic>()))
                .toList(),
    );
  }
}
