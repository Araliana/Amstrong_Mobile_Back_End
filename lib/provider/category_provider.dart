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

  //Setter untuk status loading
  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  //Ambil semua kategori dari database
  Future<void> loadCategories(CategoryType type) async {
    _setLoading(true);
    final res = await db.get(
      type == CategoryType.menu ? dishTypeTable : productTypeTable,
      orderBy: "id",
      orderType: OrderType.asc,
    );

    categories
      ..clear()
      ..addAll(res.map((e) => Category.fromMap(e)).toList());

    _setLoading(false);
  }

  //Tambah kategori baru
  Future<void> addCategory(CategoryType type, String name) async {
    _setLoading(true);

    final id = await db.insert(
      type == CategoryType.menu ? dishTypeTable : productTypeTable,
      {'name': name},
    );

    categories.add(Category(id: id, name: name, createdAt: DateTime.now()));

    _setLoading(false);
  }

  Future<void> editCategory(
    CategoryType type, {
    required int id,
    String? name,
  }) async {
    _setLoading(true);

    final oldData = await db.get(
      type == CategoryType.menu ? dishTypeTable : productTypeTable,
      where: "id = ?",
      whereArgs: [id],
    );
    if (oldData.isEmpty) {
      _setLoading(false);
      return;
    }

    final current = Category.fromMap(oldData.first);

    await db.update(
      type == CategoryType.menu ? dishTypeTable : productTypeTable,
      id: id,
      data: {'name': name ?? current.name},
    );

    final index = categories.indexWhere((item) => item.id == id);
    if (index != -1) {
      categories[index] = Category(
        id: id,
        name: name ?? current.name,
        createdAt: current.createdAt,
      );
    }

    _setLoading(false);
  }

  Future<void> deleteCategory(CategoryType type, int id) async {
    _setLoading(true);
    await db.delete(
      type == CategoryType.menu ? dishTypeTable : productTypeTable,
      id: id,
    );
    categories.removeWhere((item) => item.id == id);
    _setLoading(false);
  }

  Future<Category?> checkCategoryName(
    CategoryType type,
    String name, {
    int? excludeId,
  }) async {
    _setLoading(true);

    final res = await db.get(
      type == CategoryType.menu ? dishTypeTable : productTypeTable,
      where: "LOWER(name) = LOWER(?) ${excludeId != null ? 'AND id != ?' : ''}",
      whereArgs: excludeId != null ? [name, excludeId] : [name],
    );

    _setLoading(false);

    if (res.isEmpty) return null;
    return Category.fromMap(res.first);
  }
}
