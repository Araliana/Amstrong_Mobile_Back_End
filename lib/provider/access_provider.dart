import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/model/access.dart';

class AccessProvider with ChangeNotifier {
  final List<Access> accesses = [];
  final DBHelper db = DBHelper();
  final Tables tables = Tables.access;

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
    final res = await db.get(tables);
    accesses
      ..clear()
      ..addAll(res.map((e) => Access.fromMap(e)).toList());
    _setLoading(false);
  }

  Future<void> addAccess({
    required String name,
    required String accessPath,
    required String category,
  }) async {
    _setLoading(true);
    final res = await db.insert(tables, {
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
        createdAt: DateTime.now(),
      ),
    );
    _setLoading(false);
  }

  Future<void> editAccess({
    required String name,
    required String accessPath,
    required String category,
    required int id,
  }) async {
    _setLoading(true);
    final access = Access.fromMap(
      (await db.get(tables, where: "id = ?", whereArgs: [id]))[0],
    );

    await db.update(tables, id, {
      'name': name,
      'access_path': accessPath,
      'category': category,
    });

    final index = accesses.indexWhere((item) => item.id == id);
    accesses[index] = Access(
      id: id,
      name: name,
      accessPath: accessPath,
      category: category,
      createdAt: access.createdAt,
    );
    _setLoading(false);
  }

  Future<void> deleteAccess(int id) async {
    _setLoading(true);
    await db.delete(tables, id: id);
    accesses.removeWhere((item) => item.id == id);
    _setLoading(false);
  }

  Future<void> deleteAllAccesses() async {
    _setLoading(true);
    await db.delete(tables);
    accesses.clear();
    _setLoading(false);
  }
}
