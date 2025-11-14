import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/model/category.dart';
import 'package:flutter_application_1/db/db_helper.dart';

enum CategoryType { menu, product }

class CategoryProvider with ChangeNotifier {
  final List<Category> categories = [];
  final DBHelper db = DBHelper();

  final Tables productTypeTable = Tables.productType;
  final Tables dishTypeTable = Tables.dishType;

  bool isLoading = false;

  // PRIVATE SET LOADING STATE
  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // AUTO-SEED DISH TYPE (HANYA UNTUK CATEGORYType.menu)
  Future<void> seedDefaultDishTypes() async {
    final res = await db.get(dishTypeTable);

    // Jika sudah ada data → jangan seed lagi
    if (res.isNotEmpty) return;

    final defaultTypes = [
      "Main Course",
      "Appetizer",
      "Dessert",
      "Side Dish",
      "Beverage",
    ];

    for (final name in defaultTypes) {
      await db.insert(dishTypeTable, {"name": name});
    }
  }

  // LOAD CATEGORY
  Future<void> loadCategories(CategoryType type) async {
    _setLoading(true);

    final res = await db.get(
      type == CategoryType.menu ? dishTypeTable : productTypeTable,
      orderBy: "id",
      orderType: OrderType.asc,
    );

    categories
      ..clear()
      ..addAll(res.map((e) => Category.fromMap(e)));

    _setLoading(false);
  }

  // ADD CATEGORY
  Future<void> addCategory(CategoryType type, String name) async {
    _setLoading(true);

    final table = type == CategoryType.menu ? dishTypeTable : productTypeTable;

    final id = await db.insert(table, {"name": name});

    categories.add(Category(id: id, name: name, createdAt: DateTime.now()));

    _setLoading(false);
  }

  // EDIT CATEGORY
  Future<void> editCategory(
    CategoryType type, {
    required int id,
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

  // DELETE CATEGORY
  Future<void> deleteCategory(CategoryType type, int id) async {
    _setLoading(true);

    final table = type == CategoryType.menu ? dishTypeTable : productTypeTable;

    await db.delete(table, id: id);

    categories.removeWhere((c) => c.id == id);

    _setLoading(false);
  }

  // CHECK DUPLICATE NAME
  Future<Category?> checkCategoryName(
    CategoryType type,
    String name, {
    int? excludeId,
  }) async {
    _setLoading(true);

    final table = type == CategoryType.menu ? dishTypeTable : productTypeTable;

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
