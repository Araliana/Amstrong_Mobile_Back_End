import 'package:flutter_application_1/model/role.dart';

class UserAdmin {
  final String id;
  final String fullname;
  final String username;
  final String? img;
  final String password;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final String roleId;
  final Role? role;

  UserAdmin({
    required this.id,
    required this.fullname,
    required this.username,
    this.img,
    required this.password,
    this.lastLogin,
    required this.createdAt,
    required this.roleId,
    this.role,
  });

  factory UserAdmin.fromMap(Map<String, dynamic> map) {
    return UserAdmin(
      id: map['id'] as String,
      fullname: map['fullname'] as String,
      username: map['username'] as String,
      img: map['img'] as String?,
      password: map['password'] as String,
      lastLogin: map['last_login'] != null
          ? DateTime.parse(map['last_login'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
      roleId: map['role_id'],
      role: map['role'] == null
          ? null
          : Role.fromMap((map['role'] as Map).cast<String, dynamic>()),
    );
  }
}
