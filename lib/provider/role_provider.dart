import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/model/access.dart';
import 'package:flutter_application_1/model/role.dart';

class RoleProvider with ChangeNotifier {
  final List<Role> roles = [];
  final DBHelper db = DBHelper();
  final Tables roleTable = Tables.role;
  final Tables accessTable = Tables.access;
  final Tables roleAccessTable = Tables.roleAccess;

  bool isLoading = false;

  RoleProvider() {
    _loadRole();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> _loadRole() async {
    _setLoading(true);
    final res = await db.get(
      roleTable,
      joins: [
        Join(joinTable: roleAccessTable, fromKey: 'id', toKey: 'role_id'),
        Join(
          joinTable: accessTable,
          fromKey: 'access_id',
          toKey: 'id',
          fromTable: roleAccessTable,
        ),
      ],
      orderType: OrderType.asc,
      orderBy: "role.id",
    );
    print(res);
    roles
      ..clear()
      ..addAll(res.map((e) => Role.fromMap(e)).toList());
    _setLoading(false);
  }

  Future<Role> getRole(int id) async {
    _setLoading(true);
    final res = (await db.get(
      Tables.role,
      joins: [
        Join(joinTable: Tables.roleAccess, fromKey: 'id', toKey: 'role_id'),
        Join(
          joinTable: Tables.access,
          fromKey: 'access_id',
          toKey: 'id',
          fromTable: Tables.roleAccess,
        ),
      ],
      where: "role.id = ?",
      whereArgs: [id],
    ))[0];
    _setLoading(false);
    return Role.fromMap(res);
  }

  Future<void> addRole({
    required String name,
    required Set<int> accesses,
  }) async {
    _setLoading(true);
    final res = await db.insert(roleTable, {'name': name});
    final List<Access> newAcc = [];
    for (int access in accesses) {
      newAcc.add(
        Access.fromMap(
          (await db.get(accessTable, where: "id = ?", whereArgs: [access]))[0],
        ),
      );
      await db.insert(roleAccessTable, {'role_id': res, "access_id": access});
    }

    roles.add(Role(id: res, name: name, access: newAcc));
    _setLoading(false);
  }

  Future<void> editRole({
    required String name,
    required Set<int> accesses,
    required int id,
  }) async {
    _setLoading(true);
    final role = Role.fromMap(
      (await db.get(Tables.role, where: "id = ?", whereArgs: [id]))[0],
    );
    await db.delete(roleAccessTable, where: "role_id", whereArgs: [id]);
    final List<Access> newAcc = [];
    for (int access in accesses) {
      newAcc.add(
        Access.fromMap(
          (await db.get(accessTable, where: "id = ?", whereArgs: [access]))[0],
        ),
      );
      await db.insert(roleAccessTable, {'role_id': id, "access_id": access});
    }
    await db.update(roleTable, id, {'name': name});

    final index = roles.indexWhere((item) => item.id == id);
    roles[index] = Role(id: id, name: role.name, access: newAcc);
    _setLoading(false);
  }

  Future<void> deleteRole(int id) async {
    _setLoading(true);
    await db.delete(roleTable, id: id);
    await db.delete(roleAccessTable, where: "role_id", whereArgs: [id]);
    roles.removeWhere((item) => item.id == id);
    _setLoading(false);
  }
}
