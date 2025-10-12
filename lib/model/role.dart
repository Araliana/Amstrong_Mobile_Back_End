import 'package:flutter_application_1/model/access.dart';

class Role {
  final int id;
  final String name;
  final List<Access>? access;

  Role({required this.id, required this.name, this.access});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'accesses': access?.map((acc) => acc.toMap()).toList(),
    };
  }

  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      id: map['id'],
      name: map['name'],
      access: map['accesses'] == null
          ? null
          : (map['accesses'] as List)
                .map((e) => Access.fromMap((e as Map).cast<String, dynamic>()))
                .toList(),
    );
  }
}
