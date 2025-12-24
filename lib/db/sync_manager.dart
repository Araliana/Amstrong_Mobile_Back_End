import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/db/seeds.dart';
import 'package:flutter_application_1/utils/index.dart';
import 'package:uuid/uuid.dart';

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
    await _pushLocalToFirestore(table);
    await _pullFirestoreToLocal(table);
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
      final data = doc.data();
      final id = doc.id;

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
}

class StructuralBootstrapService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final uuid = const Uuid();

  Map<String, FieldValue?> baseTimestamps() {
    return {
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'deleted_at': null,
    };
  }

  Future<void> bootstrapIfNeeded() async {
    final metaRef = firestore.collection('meta').doc('app');
    final metaSnap = await metaRef.get();

    if (metaSnap.exists) {
      print('✅ Struktur sudah ada');
      return;
    }

    // 1️⃣ ROLES
    final roleIds = <int, String>{};
    final roleNames = ["Master", "Owner", "Staff"];

    for (int i = 0; i < roleNames.length; i++) {
      final id = uuid.v4();
      roleIds[i + 1] = id;

      await firestore.collection('roles').doc(id).set({
        'id': id,
        'name': roleNames[i],
        ...baseTimestamps(),
      });
    }

    // 2️⃣ ACCESS + ROLE_ACCESS
    int globalIndex = 0;

    final Map<String, List<DataPermission>> permissions = {
      "ORDERS": [
        DataPermission(
          name: "All Orders",
          accessPath: "/orders",
          icon: "orders",
        ),
        DataPermission(
          name: "Pending Orders",
          accessPath: "/pending-order",
          icon: "orders_pending",
        ),
        DataPermission(
          name: "Completed Orders",
          accessPath: "/completed-orders",
          icon: "orders_completed",
        ),
      ],
      "PRODUCTS & STOCK": [
        DataPermission(
          name: "Products",
          accessPath: "/products",
          icon: "products",
        ),
        DataPermission(
          name: "Categories",
          accessPath: "/categories",
          icon: "categories",
        ),
        DataPermission(
          name: "Inventory",
          accessPath: "/inventory",
          icon: "inventory",
        ),
      ],
      "FINANCE": [
        DataPermission(
          name: "Cash Flow",
          accessPath: "/cash-flow",
          icon: "cashflow",
        ),
        DataPermission(name: "Report", accessPath: "/report", icon: "report"),
      ],
      "CONTENT & MEDIA": [
        DataPermission(name: "Menu", accessPath: "/menu", icon: "menu_food"),
        DataPermission(
          name: "Dish Types",
          accessPath: "/dish-types",
          icon: "dish_types",
        ),
        DataPermission(
          name: "Gallery",
          accessPath: "/gallery",
          icon: "gallery",
        ),
      ],
      "MANAGEMENT": [
        DataPermission(
          name: "Admin Users",
          accessPath: "/user-admin",
          icon: "user_admin",
        ),
        DataPermission(name: "Roles", accessPath: "/roles", icon: "roles"),
        DataPermission(
          name: "Accesses",
          accessPath: "/accesses",
          icon: "accesses",
        ),
      ],
    };

    final exclude = {
      1: [],
      2: [12, 13, 14],
      3: [7, 8, 12, 13, 14],
    };

    for (var entry in permissions.entries) {
      for (var access in entry.value) {
        final accessId = uuid.v4();
        final sortIndex = ++globalIndex;

        await firestore.collection('access').doc(accessId).set({
          'id': accessId,
          'name': access.name,
          'access_path': access.accessPath,
          'category': entry.key,
          'icon': access.icon,
          'id_sort': sortIndex,
          ...baseTimestamps(),
        });

        for (int role = 1; role <= 3; role++) {
          if (!exclude[role]!.contains(sortIndex - 1)) {
            await firestore.collection('role_access').add({
              'role_id': roleIds[role],
              'access_id': accessId,
              ...baseTimestamps(),
            });
          }
        }
      }
    }

    // 3️⃣ MASTER ADMIN
    await firestore.collection('user_admin').add({
      'id': uuid.v4(),
      'username': 'admin',
      'password': hashPassword("Asdf1234!"),
      'role_id': roleIds[1],
      'fullname': 'Master',
      ...baseTimestamps(),
    });

    // 4️⃣ LOCK
    await metaRef.set({
      'bootstrapped': true,
      'created_at': FieldValue.serverTimestamp(),
    });

    print('✅ Bootstrap selesai (with timestamps)');
  }
}
