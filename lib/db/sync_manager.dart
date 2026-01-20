import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/db/db_helper.dart';

class SyncManager {
  final DBHelper dbHelper = DBHelper();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> syncAll() async {
    try {
      for (var table in Tables.values) {
        await syncTable(table);
      }
    } catch (e) {
      print('Error during syncAll: $e');
    }
  }

  Future<void> syncTable(Tables table) async {
    try {
      await _pushLocalToFirestore(table);
      await _pullFirestoreToLocal(table);
    } catch (e) {
      print('Error syncing table $table: $e');
    }
  }

  Future<void> _pushLocalToFirestore(Tables table) async {
    final db = await dbHelper.database;
    final tableName = DBHelper.tableNames[table]!;
    final col = firestore.collection(tableName);

    final unsynced = await db.query(tableName, where: "is_synced = 0");

    for (var row in unsynced) {
      final id = row['id'];

      final data = Map<String, dynamic>.from(row)..remove('is_synced');

      await col.doc(id as String).set({
        ...data,
        'id': id,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await db.update(
        tableName,
        {"is_synced": 1},
        where: "id = ?",
        whereArgs: [id],
      );
    }
  }

  Future<void> _pullFirestoreToLocal(Tables table) async {
    final db = await dbHelper.database;
    final tableName = DBHelper.tableNames[table]!;
    final col = firestore.collection(tableName);

    final serverDocs = await col.get();

    for (var doc in serverDocs.docs) {
      final data = normalize(doc.data());
      final id = data['id'];

      final local = await db.query(tableName, where: "id = ?", whereArgs: [id]);

      if (local.isEmpty) {
        await dbHelper.insert(table, {...data, "is_synced": 1});
        continue;
      }

      final localRow = local.first;

      final serverUpdated = DateTime.tryParse(data['updated_at'] ?? '');
      final localUpdated = DateTime.tryParse(
        localRow['updated_at']?.toString() ?? '',
      );

      if (serverUpdated == null || localUpdated == null) {
        continue;
      }

      if (serverUpdated.isAfter(localUpdated)) {
        await dbHelper.update(table, id: id, data: {...data, "is_synced": 1});
      }
    }
  }

  Map<String, dynamic> normalize(Map<String, dynamic> data) {
    final map = Map<String, dynamic>.from(data);

    for (final k in ['created_at', 'updated_at', 'deleted_at']) {
      if (map[k] is Timestamp) {
        map[k] = (map[k] as Timestamp).toDate().toIso8601String();
      }
    }

    return map;
  }
}
