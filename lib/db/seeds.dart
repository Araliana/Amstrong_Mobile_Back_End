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
    "img": null,
    "password": hashPassword("Asdf1234!"),
    "role_id": 1,
    "last_login": null,
  });

  final List<String> roles = ["Master", "Owner", "Staff"];
  for (String role in roles) {
    await db.insert(tableNames[Tables.role]!, {"name": role});
  }

  final Map<String, List<DataPermision>> permisions = {
    "ORDERS": [
      DataPermision(name: "All Orders", accessPath: "/access-path"),
      DataPermision(name: "Pending Orders", accessPath: "/pending-path"),
      DataPermision(name: "Completed Orders", accessPath: "/completed-path"),
    ],
    "PRODUCTS & STOCK": [
      DataPermision(name: "Products", accessPath: "/products"),
      DataPermision(name: "Categories", accessPath: "/categories"),
      DataPermision(name: "Inventory", accessPath: "/inventory"),
    ],
    "FINANCE": [
      DataPermision(name: "Cash Flow", accessPath: "/cash-flow"),
      DataPermision(name: "Report", accessPath: "/report"),
    ],
    "CONTENT & MEDIA": [
      DataPermision(name: "Menu", accessPath: "/menu"),
      DataPermision(name: "Dish Types", accessPath: "/dish-types"),
      DataPermision(name: "Gallery", accessPath: "/gallery"),
    ],
    "MANAGEMENT": [
      DataPermision(name: "Admin Users", accessPath: "/admin-users"),
      DataPermision(name: "Roles", accessPath: "/dish-types"),
      DataPermision(name: "Accesses", accessPath: "/accesses"),
    ],
  };

  final exclude = {
    1: [],
    2: [12, 13, 14],
    3: [7, 8, 12, 13, 14],
  };
  for (var entry in permisions.entries) {
    final String category = entry.key;
    final List<DataPermision> perms = entry.value;

    for (var access in perms) {
      final accessId = await db.insert(tableNames[Tables.access]!, {
        "name": access.name,
        "access_path": access.accessPath,
        "category": category,
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

class DataPermision {
  final String name;
  final String accessPath;

  DataPermision({required this.name, required this.accessPath});
}
