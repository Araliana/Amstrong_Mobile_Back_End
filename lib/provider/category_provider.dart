import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/db/sync_manager.dart';
import 'package:flutter_application_1/model/category.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:uuid/uuid.dart';

enum CategoryType { menu, product }

class CategoryProvider with ChangeNotifier {
  final List<Category> categories = [];
  final DBHelper db = DBHelper();

  final Tables productTypeTable = Tables.productType;
  final Tables dishTypeTable = Tables.dishType;
  final uuid = const Uuid();
  final sync = SyncManager();

  bool isLoading = false;

  void _setLoading(bool value) {
    isLoading = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> loadCategories(CategoryType type) async {
    _setLoading(true);
    final table = type == CategoryType.menu ? dishTypeTable : productTypeTable;
    await sync.syncTable(table);

    final res = await db.get(table, orderBy: "id", orderType: OrderType.asc);

    categories
      ..clear()
      ..addAll(res.map((e) => Category.fromMap(e)));

    _setLoading(false);
  }

  Future<void> addCategory(CategoryType type, String name) async {
    _setLoading(true);
    final id = uuid.v4();

    final table = type == CategoryType.menu ? dishTypeTable : productTypeTable;

    await db.insert(table, {'id': id, "name": name});

    await sync.syncTable(table);

    categories.add(Category(id: id, name: name, createdAt: DateTime.now()));

    _setLoading(false);
  }

  Future<void> editCategory(
    CategoryType type, {
    required String id,
    String? name,
  }) async {
    _setLoading(true);

    final table = type == CategoryType.menu ? dishTypeTable : productTypeTable;

    final old = await db.get(table, where: "id = ?", whereArgs: [id]);

    if (old.isEmpty) {
      _setLoading(false);
      return;
    }

    final current = Category.fromMap(old.first);

    await db.update(table, id: id, data: {"name": name ?? current.name});

    await sync.syncTable(table);
    final index = categories.indexWhere((cat) => cat.id == id);
    if (index != -1) {
      categories[index] = Category(
        id: id,
        name: name ?? current.name,
        createdAt: current.createdAt,
      );
    }

    _setLoading(false);
  }

  Future<void> deleteCategory(CategoryType type, String id) async {
    _setLoading(true);

    final table = type == CategoryType.menu ? dishTypeTable : productTypeTable;

    await db.delete(table, id: id);

    await sync.syncTable(table);
    categories.removeWhere((c) => c.id == id);

    _setLoading(false);
  }

  Future<Category?> checkCategoryName(
    CategoryType type,
    String name, {
    int? excludeId,
  }) async {
    _setLoading(true);

    final table = type == CategoryType.menu ? dishTypeTable : productTypeTable;
    await sync.syncTable(table);

    final res = await db.get(
      table,
      where: "LOWER(name) = LOWER(?) ${excludeId != null ? 'AND id != ?' : ''}",
      whereArgs: excludeId != null ? [name, excludeId] : [name],
    );

    _setLoading(false);

    if (res.isEmpty) return null;

    return Category.fromMap(res.first);
  }
}
