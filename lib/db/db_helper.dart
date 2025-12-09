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
  productType,
  dishType,
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
  static const int _dbVersion = 1; // Increment version untuk migration

  static final Map<Tables, String> tableSchemas = {
    Tables.userAdmin: '''
      CREATE TABLE user_admin(
        id TEXT PRIMARY KEY,
        fullname VARCHAR,
        username VARCHAR,
        img VARCHAR,
        password VARCHAR,
        role_id TEXT,
        last_login DATETIME,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME,
        deleted_at DATETIME,
        is_synced INTEGER DEFAULT 0
      )
    ''',
    Tables.role: '''
      CREATE TABLE role(
        id TEXT PRIMARY KEY,
        name VARCHAR,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME,
        deleted_at DATETIME,
        is_synced INTEGER DEFAULT 0
      )
    ''',
    Tables.access: '''
      CREATE TABLE access(
        id TEXT PRIMARY KEY,
        name VARCHAR,
        access_path VARCHAR,
        category VARCHAR,
        id_sort INTEGER,
        icon VARCHAR,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME,
        deleted_at DATETIME,
        is_synced INTEGER DEFAULT 0
      )
    ''',
    Tables.product: '''
      CREATE TABLE product(
        id TEXT PRIMARY KEY,
        name VARCHAR,
        discount REAL,
        img VARCHAR,
        description TEXT
        profit_type VARCHAR,
        profit_amount REAL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME,
        deleted_at DATETIME,
        is_synced INTEGER DEFAULT 0
      )
    ''',
    Tables.roleAccess: '''
      CREATE TABLE role_access(
        role_id TEXT,
        access_id TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME,
        deleted_at DATETIME,
        is_synced INTEGER DEFAULT 0
      )
    ''',
    Tables.menu: '''
      CREATE TABLE menu (
        id TEXT PRIMARY KEY,
        name VARCHAR,
        img VARCHAR,
        price REAL,
        description VARCHAR,
        type_id INTEGER,
        is_active INTEGER DEFAULT 1,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME,
        deleted_at DATETIME,
        is_synced INTEGER DEFAULT 0
      )
      ''',
    Tables.gallery: '''
      CREATE TABLE gallery (
        id TEXT PRIMARY KEY,
        name VARCHAR,
        category VARCHAR,
        quote VARCHAR,
        img VARCHAR,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME,
        deleted_at DATETIME,
        is_synced INTEGER DEFAULT 0
      )
      ''',
    Tables.productType: '''
      CREATE TABLE product_type (
        id TEXT PRIMARY KEY,
        name VARCHAR,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME,
        deleted_at DATETIME,
        is_synced INTEGER DEFAULT 0
      )
      ''',
    Tables.dishType: '''
      CREATE TABLE dish_type (
        id TEXT PRIMARY KEY,
        name VARCHAR,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME,
        deleted_at DATETIME,
        is_synced INTEGER DEFAULT 0
      )
      ''',
  };

  static final Map<int, List<String>> tableMigrations = {};

  static final Map<Tables, String> tableNames = {
    Tables.userAdmin: "user_admin",
    Tables.role: "role",
    Tables.access: "access",
    Tables.product: "product",
    Tables.roleAccess: "role_access",
    Tables.gallery: "gallery",
    Tables.menu: "menu",
    Tables.productType: "product_type",
    Tables.dishType: "dish_type",
  };

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), "app.db");
    // await deleteDatabase(path);
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
              try {
                await db.execute(script);
              } catch (e) {
                // Kolom mungkin sudah ada atau error lain, skip
                // ignore: avoid_print
                print('Migration skipped for: $script. Error: $e');
              }
            }
          }
        }
      },
    );
  }

  Future<void> clearDB() async {
    final path = join(await getDatabasesPath(), "app.db");
    if (_db != null) {
      await _db!.close();
    }
    await deleteDatabase(path);
    _db = null;
  }

  Future<int> insert(Tables table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(tableNames[table]!, data);
  }

  Future<int> update(
    Tables table, {
    String? id,
    String? where,
    List<Object?>? whereArgs,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    final tableName = tableNames[table]!;

    data['updated_at'] = DateTime.now().toIso8601String();

    final buffer = StringBuffer();
    final args = <Object?>[];

    if (where != null && where.isNotEmpty) {
      buffer.write(where);
      if (whereArgs != null) args.addAll(whereArgs);
    }

    if (id != null) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write('id = ?');
      args.add(id);
    }

    return await db.update(
      tableName,
      data,
      where: buffer.isEmpty ? null : buffer.toString(),
      whereArgs: buffer.isEmpty ? null : args,
    );
  }

  Future<int> delete(
    Tables table, {
    String? id,
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    final tableName = tableNames[table]!;

    final now = DateTime.now().toIso8601String();

    final data = {'deleted_at': now};

    final buffer = StringBuffer();
    final args = <Object?>[];

    if (where != null && where.isNotEmpty) {
      buffer.write(where);
      if (whereArgs != null) args.addAll(whereArgs);
    }

    if (id != null) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write('id = ?');
      args.add(id);
    }

    return await db.update(
      tableName,
      data,
      where: buffer.isEmpty ? null : buffer.toString(),
      whereArgs: buffer.isEmpty ? null : args,
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

    final baseCols = await _getColumns(baseTable);
    query.write("SELECT ");
    query.write(
      baseCols.map((c) => "$baseTable.$c AS ${baseTable}_$c").join(", "),
    );

    final joinTables = <String>[];
    final listTables = <String>[];

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

    query.write(" FROM $baseTable");

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

    final whereClause = StringBuffer();
    final whereArgsList = <Object?>[];

    whereClause.write("$baseTable.deleted_at IS NULL");

    if (where != null && where.isNotEmpty) {
      whereClause.write(" AND ($where)");
      if (whereArgs != null) whereArgsList.addAll(whereArgs);
    }

    query.write(" WHERE ${whereClause.toString()}");

    if (orderBy != null) {
      query.write(" ORDER BY $orderBy ${orderType.sql}");
    } else {
      query.write(" ORDER BY $baseTable.id ${orderType.sql}");
    }

    final rows = await db.rawQuery(query.toString(), whereArgsList);

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
    final seen = <dynamic, Map<String, dynamic>>{};

    for (var row in rows) {
      final baseData = <String, dynamic>{};
      final nestedData = <String, dynamic>{};

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
