import 'package:flutter/material.dart';
import 'package:flutter_application_1/db_helper.dart';
import 'package:flutter_application_1/model/user_admin.dart';
import 'package:flutter_application_1/utils/index.dart';

class LogProvider with ChangeNotifier {
  final List<UserAdmin> userAdmins = [];
  final DBHelper db = DBHelper();
  final Tables tables = Tables.userAdmin;

  LogProvider() {
    _loadUserAdmin();
  }

  Future<void> _loadUserAdmin() async {
    final res = await db.get(tables);
    userAdmins
      ..clear()
      ..addAll(res.map((e) => UserAdmin.fromMap(e)).toList());
    notifyListeners();
  }

  Future<void> addUserAdmin({
    required String username,
    required String password,
  }) async {
    final res = await db.insert(tables, {
      'username': username,
      'password': password,
    });
    userAdmins.add(
      UserAdmin(
        id: res,
        username: username,
        password: hashPassword(password),
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  Future<void> editItem({
    String? username,
    String? password,
    String? img,
    required int id,
  }) async {
    final userAdmin = UserAdmin.fromMap(
      (await db.get(tables, where: "id = ?", whereArgs: [id]))[0],
    );
    await db.update(tables, id, {'username': username});
    final index = userAdmins.indexWhere((item) => item.id == id);
    userAdmins[index] = UserAdmin(
      id: id,
      username: username ?? userAdmin.username,
      password: password ?? hashPassword(userAdmin.password),
      img: img ?? userAdmin.img,
      lastLogin: userAdmin.lastLogin,
      createdAt: userAdmin.createdAt,
    );
    notifyListeners();
  }

  Future<void> deleteItem(int id) async {
    await db.delete(tables, id);
    final index = userAdmins.indexWhere((item) => item.id == id);
    userAdmins.removeAt(index);
    notifyListeners();
  }

  Future<void> deleteAllUserAdmins() async {
    await db.delete(tables);
    userAdmins.clear();
    notifyListeners();
  }
}
