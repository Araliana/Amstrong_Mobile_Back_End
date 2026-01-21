import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/utils/index.dart';
import 'package:uuid/uuid.dart';

class SeedService {
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

      await firestore.collection(DBHelper.tableNames[Tables.role]!).doc(id).set(
        {'id': id, 'name': roleNames[i], ...baseTimestamps()},
      );
    }

    // 2️⃣ ACCESS + ROLE_ACCESS
    int globalIndex = 0;

    final Map<String, List<DataPermission>> permissions = {
      "ORDERS": [
        DataPermission(
          name: "All Orders",
          nameId: "Semua Pesanan",
          accessPath: "/orders",
          icon: "orders",
        ),
        DataPermission(
          name: "Pending Orders",
          nameId: "Pesanan Tertunda",
          accessPath: "/pending-order",
          icon: "orders_pending",
        ),
        DataPermission(
          name: "Completed Orders",
          nameId: "Pesanan Selesai",
          accessPath: "/completed-orders",
          icon: "orders_completed",
        ),
      ],
      "PRODUCTS & STOCK": [
        DataPermission(
          name: "Products",
          nameId: "Produk",
          accessPath: "/products",
          icon: "products",
        ),
        DataPermission(
          name: "Categories",
          nameId: "Kategori",
          accessPath: "/categories",
          icon: "categories",
        ),
        DataPermission(
          name: "Inventory",
          nameId: "Inventaris",
          accessPath: "/inventory",
          icon: "inventory",
        ),
      ],
      "FINANCE": [
        DataPermission(
          name: "Cash Flow",
          nameId: "Arus Kas",
          accessPath: "/cash-flow",
          icon: "cashflow",
        ),
        DataPermission(
          name: "Report",
          nameId: "Laporan",
          accessPath: "/report",
          icon: "report",
        ),
      ],
      "CONTENT & MEDIA": [
        DataPermission(
          name: "Menu",
          nameId: "Menu",
          accessPath: "/menu",
          icon: "menu_food",
        ),
        DataPermission(
          name: "Dish Types",
          nameId: "Jenis Hidangan",
          accessPath: "/dish-types",
          icon: "dish_types",
        ),
        DataPermission(
          name: "Gallery",
          nameId: "Galeri",
          accessPath: "/gallery",
          icon: "gallery",
        ),
      ],
      "MANAGEMENT": [
        DataPermission(
          name: "Admin Users",
          nameId: "Admin Pengguna",
          accessPath: "/user-admin",
          icon: "user_admin",
        ),
        DataPermission(
          name: "Roles",
          nameId: "Peran",
          accessPath: "/roles",
          icon: "roles",
        ),
        DataPermission(
          name: "Accesses",
          nameId: "Akses",
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

        await firestore
            .collection(DBHelper.tableNames[Tables.access]!)
            .doc(accessId)
            .set({
              'id': accessId,
              'name': access.name,
              'name_id': access.nameId,
              'access_path': access.accessPath,
              'category': entry.key,
              'icon': access.icon,
              'id_sort': sortIndex,
              ...baseTimestamps(),
            });

        for (int role = 1; role <= 3; role++) {
          if (!exclude[role]!.contains(sortIndex - 1)) {
            final id = uuid.v4();
            await firestore.collection('role_access').add({
              'id': id,
              'role_id': roleIds[role],
              'access_id': accessId,
              ...baseTimestamps(),
            });
          }
        }
      }
    }

    // 3️⃣ MASTER ADMIN
    await firestore.collection(DBHelper.tableNames[Tables.userAdmin]!).add({
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

class DataPermission {
  final String name;
  final String nameId;
  final String accessPath;
  final String icon;

  DataPermission({
    required this.name,
    required this.nameId,
    required this.accessPath,
    required this.icon,
  });
}
