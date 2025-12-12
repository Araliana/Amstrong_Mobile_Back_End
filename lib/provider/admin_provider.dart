import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/model/role.dart';
import 'package:flutter_application_1/model/user_admin.dart';
import 'package:flutter_application_1/utils/index.dart';
import 'package:uuid/uuid.dart';

class AdminProvider with ChangeNotifier {
  final _userController = StreamController<UserAdmin>.broadcast();
  Stream<UserAdmin> get userStream => _userController.stream;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final List<UserAdmin> userAdmins = [];
  final DBHelper db = DBHelper();
  final Tables adminTables = Tables.userAdmin;
  final Tables roleTable = Tables.role;
  final Tables accessTable = Tables.access;
  final Tables roleAccessTable = Tables.roleAccess;
  final uuid = const Uuid();

  bool isLoading = false;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> loadUserAdmin() async {
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

    await analytics.logEvent(
      name: 'load_admin',
      parameters: {'count': userAdmins.length},
    );
  }

  Future<UserAdmin> getUserById(String userId) async {
    final res = (await db.get(
      adminTables,
      joins: [
        Join(
          joinTable: roleTable,
          fromKey: "role_id",
          toKey: "id",
          isList: false,
        ),
        Join(
          joinTable: roleAccessTable,
          fromKey: 'id',
          toKey: 'role_id',
          fromTable: roleTable,
        ),
        Join(
          joinTable: accessTable,
          fromKey: 'access_id',
          toKey: 'id',
          fromTable: roleAccessTable,
        ),
      ],
      where: "user_admin.id = ?",
      whereArgs: [userId],
    ))[0];

    res["role"]["access"] = res["access"];

    await analytics.logEvent(
      name: 'get_id_by_id',
      parameters: {'count': userAdmins.length},
    );
    _userController.add(UserAdmin.fromMap(res));
    return UserAdmin.fromMap(res);
  }

  Future<void> addUserAdmin({
    required String fullname,
    required String username,
    required String password,
    required String roleId,
  }) async {
    _setLoading(true);

    final id = uuid.v4();

    await db.insert(adminTables, {
      'id': id,
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
        id: id,
        fullname: fullname,
        username: username,
        password: hashPassword(password),
        createdAt: DateTime.now(),
        roleId: roleId,
        role: role,
      ),
    );
    _setLoading(false);

    await analytics.logEvent(
      name: 'add_admin',
      parameters: {
        'fullname': fullname,
        'username': username,
        'role_id': roleId,
      },
    );
  }

  Future<void> editUserAdmin({
    String? fullname,
    String? username,
    String? password,
    String? img,
    String? roleId,
    required String id,
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
    await db.update(
      adminTables,
      id: id,
      data: {
        'fullname': fullname ?? userAdmin.fullname,
        'username': username ?? userAdmin.username,
        'img': img ?? userAdmin.img,
        'password': password != null
            ? hashPassword(password)
            : userAdmin.password,
        "role_id": roleId ?? userAdmin.roleId,
      },
    );
    if (userAdmins.indexWhere((item) => item.id == id) == -1) {
      await loadUserAdmin();
    }
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

    if (fullname != null || img != null) {
      _userController.add(userAdmins[index]);
    }

    _setLoading(false);
    await analytics.logEvent(
      name: 'edit_admin',
      parameters: {
        'id': id,
        'fullname': fullname ?? userAdmin.fullname,
        'username': username ?? userAdmin.username,
        'role_id': roleId ?? userAdmin.roleId,
      },
    );
  }

  Future<bool> changePassword({
    required String newPassword,
    required String oldPassword,
    required String id,
  }) async {
    _setLoading(true);

    final userAdmin = UserAdmin.fromMap(
      (await db.get(adminTables, where: "id = ?", whereArgs: [id]))[0],
    );

    if (!verifyPassword(oldPassword, userAdmin.password)) {
      _setLoading(false);
      return false;
    }

    await editUserAdmin(id: id, password: hashPassword(newPassword));

    _setLoading(false);

    await analytics.logEvent(name: 'change_password', parameters: {'id': id});

    return true;
  }

  Future<bool> checkUsername({required String username, String? id}) async {
    _setLoading(true);

    final query = "username = LOWER(?) ${id != null ? "AND id != ?" : ""}";
    final args = id != null ? [username, id] : [username];

    final userAdmin = await db.get(adminTables, where: query, whereArgs: args);

    _setLoading(false);

    await analytics.logEvent(
      name: 'check_username',
      parameters: {
        'username': username,
        'found': userAdmin.isNotEmpty.toString(),
        'checked_with_id': (id != null).toString(),
      },
    );

    return userAdmin.isNotEmpty;
  }

  Future<void> deleteUserAdmin(String id) async {
    _setLoading(true);
    await db.delete(adminTables, id: id);
    userAdmins.removeWhere((item) => item.id == id);
    _setLoading(false);

    await analytics.logEvent(name: 'delete_admin', parameters: {'id': id});
  }
}
