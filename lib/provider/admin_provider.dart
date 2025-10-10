import 'package:flutter/material.dart';
import 'package:flutter_application_1/db_helper.dart';
import 'package:flutter_application_1/model/user_admin.dart';
import 'package:flutter_application_1/utils/index.dart';

class AdminProvider with ChangeNotifier {
  final List<UserAdmin> userAdmins = [];
  final DBHelper db = DBHelper();
  final Tables tables = Tables.userAdmin;

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
    final res = await db.get(tables);
    userAdmins
      ..clear()
      ..addAll(res.map((e) => UserAdmin.fromMap(e)).toList());
    _setLoading(false);
  }

  Future<void> addUserAdmin({
    required String fullname,
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    final res = await db.insert(tables, {
      'fullname': fullname,
      'username': username,
      'password': hashPassword(password),
    });

    userAdmins.add(
      UserAdmin(
        id: res,
        fullname: fullname,
        username: username,
        password: hashPassword(password),
        createdAt: DateTime.now(),
      ),
    );
    _setLoading(false);
  }

  Future<void> editItem({
    String? fullname,
    String? username,
    String? password,
    String? img,
    required int id,
  }) async {
    _setLoading(true);
    final userAdmin = UserAdmin.fromMap(
      (await db.get(tables, where: "id = ?", whereArgs: [id]))[0],
    );

    await db.update(tables, id, {
      'fullname': fullname ?? userAdmin.fullname,
      'username': username ?? userAdmin.username,
      'password': password != null
          ? hashPassword(password)
          : userAdmin.password,
      'img': img ?? userAdmin.img,
    });

    final index = userAdmins.indexWhere((item) => item.id == id);
    userAdmins[index] = UserAdmin(
      id: id,
      fullname: fullname ?? userAdmin.fullname,
      username: username ?? userAdmin.username,
      password: password != null ? hashPassword(password) : userAdmin.password,
      img: img ?? userAdmin.img,
      lastLogin: userAdmin.lastLogin,
      createdAt: userAdmin.createdAt,
    );
    _setLoading(false);
  }

  Future<UserAdmin?> checkUsername({required String username, int? id}) async {
    _setLoading(true);
    final userAdmin = await db.get(
      tables,
      where: "username = ? ${id != null ? "AND id != ?" : ""}",
      whereArgs: [username],
    );
    if (userAdmin.isEmpty) {
      return null;
    }

    _setLoading(false);
    return UserAdmin.fromMap(userAdmin[0]);
  }

  Future<void> deleteItem(int id) async {
    _setLoading(true);
    await db.delete(tables, id);
    userAdmins.removeWhere((item) => item.id == id);
    _setLoading(false);
  }

  Future<void> deleteAllUserAdmins() async {
    _setLoading(true);
    await db.delete(tables);
    userAdmins.clear();
    _setLoading(false);
  }
}
