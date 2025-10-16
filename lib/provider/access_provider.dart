import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/model/access.dart';

class AccessProvider with ChangeNotifier {
  final List<Access> accesses = [];
  final DBHelper db = DBHelper();
  final Tables accessTables = Tables.access;
  final Tables roleAccessTable = Tables.roleAccess;

  bool isLoading = false;

  AccessProvider() {
    _loadAccess();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> _loadAccess() async {
    _setLoading(true);
    final res = await db.get(
      accessTables,
      orderBy: "name",
      orderType: OrderType.asc,
    );
    accesses
      ..clear()
      ..addAll(res.map((e) => Access.fromMap(e)).toList());
    _setLoading(false);
  }

  Future<void> addAccess({
    required String name,
    required String accessPath,
    required String category,
    required String icon,
  }) async {
    _setLoading(true);
    final res = await db.insert(accessTables, {
      'name': name,
      'access_path': accessPath,
      'category': category,
    });

    accesses.add(
      Access(
        id: res,
        name: name,
        accessPath: accessPath,
        category: category,
        icon: appIcons.firstWhere((item) => item.name == icon).icon,
        createdAt: DateTime.now(),
      ),
    );
    _setLoading(false);
  }

  Future<void> editAccess({
    required String name,
    required String accessPath,
    required String category,
    required String icon,
    required int id,
  }) async {
    _setLoading(true);
    final access = Access.fromMap(
      (await db.get(accessTables, where: "id = ?", whereArgs: [id]))[0],
    );

    await db.update(accessTables, id, {
      'name': name,
      'access_path': accessPath,
      'category': category,
      'icon': icon,
    });

    final index = accesses.indexWhere((item) => item.id == id);
    accesses[index] = Access(
      id: id,
      name: name,
      accessPath: accessPath,
      category: category,
      icon: appIcons.firstWhere((item) => item.name == icon).icon,
      createdAt: access.createdAt,
    );
    _setLoading(false);
  }

  Future<void> deleteAccess(int id) async {
    _setLoading(true);
    await db.delete(accessTables, id: id);
    await db.delete(roleAccessTable, where: "access_id", whereArgs: [id]);
    accesses.removeWhere((item) => item.id == id);
    _setLoading(false);
  }
}
