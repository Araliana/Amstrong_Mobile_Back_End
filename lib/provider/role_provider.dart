import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/model/access.dart';
import 'package:flutter_application_1/model/role.dart';
import 'package:uuid/uuid.dart';

class RoleProvider with ChangeNotifier {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final List<Role> roles = [];
  final DBHelper db = DBHelper();
  final Tables roleTable = Tables.role;
  final Tables accessTable = Tables.access;
  final Tables roleAccessTable = Tables.roleAccess;
  final uuid = const Uuid();

  bool isLoading = false;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> loadRole() async {
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

    roles
      ..clear()
      ..addAll(res.map((e) => Role.fromMap(e)).toList());
    _setLoading(false);

    await analytics.logEvent(
      name: 'load_role',
      parameters: {'count': roles.length},
    );
  }

  Future<Role?> getRoleById(String id) async {
    _setLoading(true);
    final res = (await db.get(
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
      where: "role.id = ?",
      whereArgs: [id],
    ))[0];
    _setLoading(false);
    await analytics.logEvent(
      name: 'get_role_detail',
      parameters: {'role_id': id},
    );
    return Role.fromMap(res);
  }

  Future<void> addRole({
    required String name,
    required Set<String> accesses,
  }) async {
    _setLoading(true);
    final id = uuid.v4();
    await db.insert(roleTable, {'id': id, 'name': name});
    final List<Access> newAcc = [];
    for (String access in accesses) {
      newAcc.add(
        Access.fromMap(
          (await db.get(accessTable, where: "id = ?", whereArgs: [access]))[0],
        ),
      );
      await db.insert(roleAccessTable, {'role_id': id, "access_id": access});
    }

    roles.add(Role(id: id, name: name, access: newAcc));
    _setLoading(false);

    await analytics.logEvent(
      name: 'add_role',
      parameters: {
        'role_id': id,
        'name': name,
        'access_count': accesses.length,
      },
    );
  }

  Future<void> editRole({
    required String name,
    required Set<String> accesses,
    required String id,
  }) async {
    _setLoading(true);
    await db.delete(roleAccessTable, where: "role_id = ?", whereArgs: [id]);
    final List<Access> newAcc = [];
    for (String access in accesses) {
      newAcc.add(
        Access.fromMap(
          (await db.get(accessTable, where: "id = ?", whereArgs: [access]))[0],
        ),
      );
      await db.insert(roleAccessTable, {'role_id': id, "access_id": access});
    }
    await db.update(roleTable, id: id, data: {'name': name});

    final index = roles.indexWhere((item) => item.id == id);
    roles[index] = Role(id: id, name: name, access: newAcc);
    _setLoading(false);

    await analytics.logEvent(
      name: 'edit_role',
      parameters: {
        'role_id': id,
        'new_name': name,
        'access_count': accesses.length,
      },
    );
  }

  Future<void> deleteRole(String id) async {
    _setLoading(true);
    await db.delete(roleTable, id: id);
    await db.delete(roleAccessTable, where: "role_id = ?", whereArgs: [id]);
    roles.removeWhere((item) => item.id == id);
    _setLoading(false);

    await analytics.logEvent(name: 'delete_role', parameters: {'role_id': id});
  }
}
