import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

enum Tables { order, menu, gallery, product, userAdmin }

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

  const Join({
    required this.joinTable,
    required this.fromKey,
    required this.toKey,
    this.joinType = JoinType.inner,
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
        last_login DATETIME,
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
  Future<int> delete(Tables table, [int? id]) async {
    final db = await database;
    return await db.delete(
      tableNames[table]!,
      where: id != null ? 'id = ?' : null,
      whereArgs: id != null ? [id] : null,
    );
  }

  Future<List<Map<String, dynamic>>> get(
    Tables table, {
    Join? join,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    OrderType orderType = OrderType.desc,
  }) async {
    final db = await database;
    final baseTable = tableNames[table]!;
    final query = StringBuffer();

    // SELECT *
    query.write("SELECT * FROM $baseTable");

    // JOIN kalau ada
    if (join != null) {
      final joinTableName = tableNames[join.joinTable]!;
      query.write(
        " ${join.joinType.sql} $joinTableName ON $baseTable.${join.fromKey} = $joinTableName.${join.toKey}",
      );
    }

    // WHERE
    if (where != null) query.write(" WHERE $where");

    // ORDER BY
    if (orderBy != null) {
      query.write(" ORDER BY $orderBy ${orderType.sql}");
    } else {
      query.write(" ORDER BY $baseTable.id ${orderType.sql}");
    }

    return await db.rawQuery(query.toString(), whereArgs);
  }
}
