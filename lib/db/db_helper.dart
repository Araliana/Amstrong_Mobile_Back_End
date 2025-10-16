import 'package:flutter_application_1/db/seeds.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

enum Tables {
  order,
  menu,
  gallery,
  product,
  userAdmin,
  role,
  access,
  roleAccess,
}

enum JoinType {
  inner,
  left,
  right;

  String get sql {
    switch (this) {
      case JoinType.inner:
        return "INNER JOIN";
      case JoinType.left:
        return "LEFT JOIN";
      case JoinType.right:
        return "RIGHT JOIN";
    }
  }
}

enum OrderType {
  asc,
  desc;

  String get sql {
    switch (this) {
      case OrderType.asc:
        return "ASC";
      case OrderType.desc:
        return "DESC";
    }
  }
}

class Join {
  final Tables joinTable;
  final String fromKey;
  final String toKey;
  final JoinType joinType;
  final bool isList;
  final Tables? fromTable;

  Join({
    required this.joinTable,
    required this.fromKey,
    required this.toKey,
    this.joinType = JoinType.inner,
    this.isList = true,
    this.fromTable,
  });
}

class DBHelper {
  static Database? _db;

  static const int _dbVersion = 1; //setiap ada perubahan pada table naikin 1

  // Definisi schema
  static final Map<Tables, String> tableSchemas = {
    Tables.userAdmin: '''
      CREATE TABLE user_admin(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullname VARCHAR,
        username VARCHAR,
        img VARCHAR,
        password VARCHAR,
        role_id INTEGER,
        last_login DATETIME,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''',
    Tables.role: '''
      CREATE TABLE role(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''',
    Tables.access: '''
      CREATE TABLE access(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR,
        access_path VARCHAR,
        category VARCHAR,
        icon VARCHAR,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''',
    Tables.roleAccess: '''
      CREATE TABLE role_access(
        role_id INTEGER,
        access_id INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''',
  };

  // Perubahan Schema
  static final Map<int, List<String>> tableMigrations = {
    // 1: ['ALTER TABLE order ADD COLUMN totalAmount REAL'],
  };

  // Mapping enum ke nama tabel
  static final Map<Tables, String> tableNames = {
    Tables.userAdmin: "user_admin",
    Tables.role: "role",
    Tables.access: "access",
    Tables.roleAccess: "role_access",
  };

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), "app.db");
    await deleteDatabase(path);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        for (var schema in tableSchemas.values) {
          await db.execute(schema);
        }
        await runSeeds(db: db, tableNames: tableNames);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        for (int i = oldVersion + 1; i <= newVersion; i++) {
          if (tableMigrations.containsKey(i)) {
            for (var script in tableMigrations[i]!) {
              await db.execute(script);
            }
          }
        }
      },
    );
  }

  // INSERT
  Future<int> insert(Tables table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(tableNames[table]!, data);
  }

  // UPDATE
  Future<int> update(Tables table, int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      tableNames[table]!,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE
  Future<int> delete(
    Tables table, {
    int? id,
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;

    if (id != null) {
      where = 'id = ?';
      whereArgs = [id];
    }

    return await db.delete(
      tableNames[table]!,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<List<Map<String, dynamic>>> get(
    Tables table, {
    List<Join>? joins,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    OrderType orderType = OrderType.desc,
  }) async {
    final db = await database;
    final baseTable = tableNames[table]!;
    final query = StringBuffer();

    // ==== SELECT BASE COLUMNS ====
    final baseCols = await _getColumns(baseTable);
    query.write("SELECT ");
    query.write(
      baseCols.map((c) => "$baseTable.$c AS ${baseTable}_$c").join(", "),
    );

    // ==== SELECT JOIN COLUMNS ====
    final joinTables = <String>[];
    final listTables = <String>[]; // tabel yang isList=true

    if (joins != null) {
      for (var j in joins) {
        final jt = tableNames[j.joinTable]!;
        joinTables.add(jt);
        if (j.isList) listTables.add(jt);

        final jtCols = await _getColumns(jt);
        query.write(", ");
        query.write(jtCols.map((c) => "$jt.$c AS ${jt}_$c").join(", "));
      }
    }

    // ==== FROM BASE TABLE ====
    query.write(" FROM $baseTable");

    // ==== JOIN CLAUSES ====
    if (joins != null) {
      for (var j in joins) {
        final jt = tableNames[j.joinTable]!;
        final fromTbl = j.fromTable != null
            ? tableNames[j.fromTable]!
            : baseTable;
        query.write(
          " ${j.joinType.sql} $jt ON $fromTbl.${j.fromKey} = $jt.${j.toKey}",
        );
      }
    }

    // ==== WHERE ====
    if (where != null) query.write(" WHERE $where");

    // ==== ORDER BY ====
    if (orderBy != null) {
      query.write(" ORDER BY $orderBy ${orderType.sql}");
    } else {
      query.write(" ORDER BY $baseTable.id ${orderType.sql}");
    }

    // Jalankan query
    final rows = await db.rawQuery(query.toString(), whereArgs);

    // Convert hasil ke nested
    return _toNested(
      rows,
      baseTable: baseTable,
      joinTables: joinTables,
      listTables: listTables,
    );
  }

  Future<List<String>> _getColumns(String table) async {
    final db = await database;
    final res = await db.rawQuery("PRAGMA table_info($table)");
    return res.map((e) => e['name'] as String).toList();
  }

  List<Map<String, dynamic>> _toNested(
    List<Map<String, dynamic>> rows, {
    required String baseTable,
    required List<String> joinTables,
    required List<String> listTables,
  }) {
    final result = <Map<String, dynamic>>[];
    final seen = <dynamic, Map<String, dynamic>>{}; // id base -> row

    for (var row in rows) {
      final baseData = <String, dynamic>{};
      final nestedData = <String, dynamic>{};

      // Pisahkan base dan nested per baris SQL
      row.forEach((key, value) {
        if (key.startsWith("${baseTable}_")) {
          baseData[key.replaceFirst("${baseTable}_", "")] = value;
        } else {
          for (var jt in joinTables) {
            if (key.startsWith("${jt}_")) {
              final col = key.replaceFirst("${jt}_", "");
              if (!nestedData.containsKey(jt)) nestedData[jt] = {};
              nestedData[jt][col] = value;
            }
          }
        }
      });

      final baseId = baseData['id'];

      if (!seen.containsKey(baseId)) {
        final newRow = Map<String, dynamic>.from(baseData);
        for (var jt in joinTables) {
          newRow[jt] = listTables.contains(jt)
              ? <Map<String, dynamic>>[]
              : null;
        }
        seen[baseId] = newRow;
        result.add(newRow);
      }

      final current = seen[baseId]!;

      nestedData.forEach((jt, data) {
        if (listTables.contains(jt)) {
          if (!(data['id'] == null)) {
            final list = current[jt] as List<Map<String, dynamic>>;
            final exists = list.any((e) => e['id'] == data['id']);
            if (!exists) list.add(data.cast<String, dynamic>());
          }
        } else {
          current[jt] = data;
        }
      });
    }

    return result;
  }
}
