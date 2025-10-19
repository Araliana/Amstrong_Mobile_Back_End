import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/model/role.dart';
import 'package:flutter_application_1/model/user_admin.dart';
import 'package:flutter_application_1/utils/index.dart';

class AdminProvider with ChangeNotifier {
  final List<UserAdmin> userAdmins = [];
  final DBHelper db = DBHelper();
  final Tables adminTables = Tables.userAdmin;
  final Tables roleTable = Tables.role;

  bool isLoading = false;

  AdminProvider() {
    _loadUserAdmin();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> _loadUserAdmin() async {
    _setLoading(true);
    final res = await db.get(
      adminTables,
      joins: [
        Join(
          joinTable: roleTable,
          fromKey: "role_id",
          toKey: "id",
          isList: false,
        ),
      ],
      orderBy: "user_admin.id",
      orderType: OrderType.asc,
    );
    userAdmins
      ..clear()
      ..addAll(res.map((e) => UserAdmin.fromMap(e)).toList());
    _setLoading(false);
  }

  Future<void> addUserAdmin({
    required String fullname,
    required String username,
    required String password,
    required int roleId,
  }) async {
    _setLoading(true);
    final res = await db.insert(adminTables, {
      'fullname': fullname,
      'username': username,
      'password': hashPassword(password),
      'role_id': roleId,
    });
    final role = Role.fromMap(
      (await db.get(roleTable, where: "id = ?", whereArgs: [roleId]))[0],
    );

    userAdmins.add(
      UserAdmin(
        id: res,
        fullname: fullname,
        username: username,
        password: hashPassword(password),
        createdAt: DateTime.now(),
        roleId: roleId,
        role: role,
      ),
    );
    _setLoading(false);
  }

  Future<void> editUserAdmin({
    String? fullname,
    String? username,
    String? password,
    String? img,
    int? roleId,
    required int id,
  }) async {
    _setLoading(true);
    final userAdmin = UserAdmin.fromMap(
      (await db.get(adminTables, where: "id = ?", whereArgs: [id]))[0],
    );
    final role = Role.fromMap(
      (await db.get(
        roleTable,
        where: "id = ?",
        whereArgs: [roleId ?? userAdmin.roleId],
      ))[0],
    );

    await db.update(adminTables, id, {
      'fullname': fullname ?? userAdmin.fullname,
      'username': username ?? userAdmin.username,
      'img': img ?? userAdmin.img,
      'password': password != null
          ? hashPassword(password)
          : userAdmin.password,
      "role_id": roleId ?? userAdmin.roleId,
    });

    final index = userAdmins.indexWhere((item) => item.id == id);
    userAdmins[index] = UserAdmin(
      id: id,
      fullname: fullname ?? userAdmin.fullname,
      username: username ?? userAdmin.username,
      img: img ?? userAdmin.img,
      password: password != null ? hashPassword(password) : userAdmin.password,
      lastLogin: userAdmin.lastLogin,
      createdAt: userAdmin.createdAt,
      roleId: roleId ?? userAdmin.roleId,
      role: role,
    );
    _setLoading(false);
  }

  Future<UserAdmin?> checkUsername({required String username, int? id}) async {
    _setLoading(true);
    final userAdmin = await db.get(
      adminTables,
      where: "username = ? ${id != null ? "AND id != ?" : ""}",
      whereArgs: [username],
    );
    if (userAdmin.isEmpty) {
      return null;
    }

    _setLoading(false);
    return UserAdmin.fromMap(userAdmin[0]);
  }

  Future<void> deleteUserAdmin(int id) async {
    _setLoading(true);
    await db.delete(adminTables, id: id);
    userAdmins.removeWhere((item) => item.id == id);
    _setLoading(false);
  }
}
