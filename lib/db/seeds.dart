import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/db/sync_manager.dart';
import 'package:flutter_application_1/utils/index.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

Future<void> runSeeds({
  required Database db,
  required Map<Tables, String> tableNames,
}) async {
  final sync = SyncManager();
  final uuid = const Uuid();

  final roleNames = ["Master", "Owner", "Staff"];
  final roleIds = <int, String>{};

  for (int i = 0; i < roleNames.length; i++) {
    final id = uuid.v4();
    roleIds[i + 1] = id;

    await db.insert(tableNames[Tables.role]!, {'id': id, 'name': roleNames[i]});
  }

  await db.insert(tableNames[Tables.userAdmin]!, {
    "id": uuid.v4(),
    "fullname": "Master",
    "username": "admin",
    "password": hashPassword("Asdf1234!"),
    "role_id": roleIds[1],
  });
  await db.insert(tableNames[Tables.userAdmin]!, {
    "id": uuid.v4(),
    "fullname": "Sendirian",
    "username": "xav",
    "password": hashPassword("Asdf1234!"),
    "role_id": roleIds[2],
  });
  await db.insert(tableNames[Tables.userAdmin]!, {
    "id": uuid.v4(),
    "fullname": "Who Are You",
    "username": "who?",
    "password": hashPassword("Asdf1234!"),
    "role_id": roleIds[3],
  });

  final Map<String, List<DataPermission>> permissions = {
    "ORDERS": [
      DataPermission(name: "All Orders", accessPath: "/orders", icon: "orders"),
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
      DataPermission(name: "Gallery", accessPath: "/gallery", icon: "gallery"),
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

  int globalIndex = 0;

  for (var entry in permissions.entries) {
    final category = entry.key;
    final perms = entry.value;

    for (int i = 0; i < perms.length; i++, globalIndex++) {
      final access = perms[i];
      final accessId = uuid.v4();

      await db.insert(tableNames[Tables.access]!, {
        'id': accessId,
        'name': access.name,
        'access_path': access.accessPath,
        'category': category,
        'icon': access.icon,
        'id_sort': globalIndex + 1,
      });

      for (int role = 1; role <= 3; role++) {
        if (!exclude[role]!.contains(globalIndex)) {
          await db.insert(tableNames[Tables.roleAccess]!, {
            'role_id': roleIds[role],
            'access_id': accessId,
          });
        }
      }
    }
  }
  await sync.syncAll();
}

class DataPermission {
  final String name;
  final String accessPath;
  final String icon;

  DataPermission({
    required this.name,
    required this.accessPath,
    required this.icon,
  });
}
