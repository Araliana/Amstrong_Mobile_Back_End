import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/utils/index.dart';
import 'package:sqflite/sqflite.dart';

Future<void> runSeeds({
  required Database db,
  required Map<Tables, String> tableNames,
}) async {
  await db.insert(tableNames[Tables.userAdmin]!, {
    "fullname": "Master",
    "username": "admin",
    "password": hashPassword("Asdf1234!"),
    "role_id": 1,
  });
  await db.insert(tableNames[Tables.userAdmin]!, {
    "fullname": "Sendirian",
    "username": "xav",
    "password": hashPassword("Asdf1234!"),
    "role_id": 2,
  });
  await db.insert(tableNames[Tables.userAdmin]!, {
    "fullname": "Who Are You",
    "username": "who?",
    "password": hashPassword("Asdf1234!"),
    "role_id": 3,
  });

  final List<String> roles = ["Master", "Owner", "Staff"];
  for (String role in roles) {
    await db.insert(tableNames[Tables.role]!, {"name": role});
  }
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
  for (var entry in permissions.entries) {
    final String category = entry.key;
    final List<DataPermission> perms = entry.value;

    for (int i = 0; i < perms.length; i++) {
      final access = perms[i];
      final accessId = await db.insert(tableNames[Tables.access]!, {
        "name": access.name,
        "access_path": access.accessPath,
        "category": category,
        "icon": access.icon,
        "id_sort": i + 1,
      });

      for (int roleId = 1; roleId <= 3; roleId++) {
        if (!exclude[roleId]!.contains(accessId)) {
          await db.insert(tableNames[Tables.roleAccess]!, {
            "role_id": roleId,
            "access_id": accessId,
          });
        }
      }
    }
  }
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
