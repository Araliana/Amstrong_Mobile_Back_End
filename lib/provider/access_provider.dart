import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/db/sync_manager.dart';
import 'package:flutter_application_1/model/access.dart';
import 'package:uuid/uuid.dart';

class AccessProvider with ChangeNotifier {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final List<Access> accesses = [];
  final DBHelper db = DBHelper();
  final Tables accessTables = Tables.access;
  final Tables roleAccessTable = Tables.roleAccess;
  final uuid = const Uuid();
  final sync = SyncManager();

  bool isLoading = false;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> loadAccess() async {
    _setLoading(true);
    await sync.syncTable(accessTables);
    await sync.syncTable(roleAccessTable);
    final res = await db.get(accessTables);

    accesses
      ..clear()
      ..addAll(res.map((e) => Access.fromMap(e)).toList());
    _setLoading(false);

    await analytics.logEvent(
      name: 'load_access',
      parameters: {'count': accesses.length},
    );
  }

  Future<void> addAccess({
    required String name,
    required String accessPath,
    required String category,
    required int idSort,
    required String icon,
  }) async {
    _setLoading(true);

    final id = uuid.v4();

    await db.insert(accessTables, {
      "id": id,
      'name': name,
      'access_path': accessPath,
      'category': category,
      'id_sort': idSort,
    });

    await sync.syncTable(accessTables);
    await sync.syncTable(roleAccessTable);

    accesses.add(
      Access(
        id: id,
        name: name,
        accessPath: accessPath,
        category: category,
        idSort: idSort,
        iconName: icon,
        icon: appIcons.firstWhere((item) => item.name == icon).icon,
        createdAt: DateTime.now(),
      ),
    );
    _setLoading(false);

    await analytics.logEvent(
      name: 'add_access',
      parameters: {'name': name, 'category': category, 'path': accessPath},
    );
  }

  Future<void> editAccess({
    required String name,
    required String accessPath,
    required String category,
    required int idSort,
    required String icon,
    required String id,
  }) async {
    _setLoading(true);
    final access = Access.fromMap(
      (await db.get(accessTables, where: "id = ?", whereArgs: [id]))[0],
    );

    await db.update(
      accessTables,
      id: id,
      data: {
        'name': name,
        'access_path': accessPath,
        'category': category,
        'id_sort': idSort,
        'icon': icon,
      },
    );
    await sync.syncTable(accessTables);
    await sync.syncTable(roleAccessTable);

    final index = accesses.indexWhere((item) => item.id == id);
    accesses[index] = Access(
      id: id,
      name: name,
      accessPath: accessPath,
      category: category,
      idSort: idSort,
      iconName: icon,
      icon: appIcons.firstWhere((item) => item.name == icon).icon,
      createdAt: access.createdAt,
    );
    _setLoading(false);

    await analytics.logEvent(
      name: 'edit_access',
      parameters: {'id': id, 'name': name, 'category': category},
    );
  }

  Future<void> deleteAccess(String id) async {
    _setLoading(true);
    await db.delete(accessTables, id: id);
    await db.delete(roleAccessTable, where: "access_id", whereArgs: [id]);

    await sync.syncTable(accessTables);
    await sync.syncTable(roleAccessTable);

    accesses.removeWhere((item) => item.id == id);
    _setLoading(false);

    await analytics.logEvent(name: 'delete_access', parameters: {'id': id});
  }
}
