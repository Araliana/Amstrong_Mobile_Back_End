import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/model/category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_application_1/db/db_helper.dart';

class CategoryProvider with ChangeNotifier {
  final List<Category> categories = [];
  final DBHelper db = DBHelper();
  final Tables categoryTable = Tables.category;

  bool isLoading = false;

  CategoryProvider() {
    _loadCategories();
  }

  /// 🔹 Setter untuk status loading
  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  /// 🔹 Ambil semua kategori dari database
  Future<void> _loadCategories() async {
    _setLoading(true);
    final res = await db.get(
      categoryTable,
      orderBy: "id",
      orderType: OrderType.asc,
    );

    categories
      ..clear()
      ..addAll(res.map((e) => Category.fromMap(e)).toList());

    _setLoading(false);
  }

  /// 🔹 Tambah kategori baru
  Future<void> addCategory(String name) async {
    _setLoading(true);

    final id = await db.insert(categoryTable, {
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
    });

    categories.add(Category(id: id, name: name, createdAt: DateTime.now()));

    _setLoading(false);
  }

  Future<void> editCategory({required int id, String? name}) async {
    _setLoading(true);

    final oldData = await db.get(
      categoryTable,
      where: "id = ?",
      whereArgs: [id],
    );
    if (oldData.isEmpty) {
      _setLoading(false);
      return;
    }

    final current = Category.fromMap(oldData.first);

    await db.update(categoryTable, id, {
      'name': name ?? current.name,
      'created_at': current.createdAt.toIso8601String(),
    });

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

  Future<void> deleteCategory(int id) async {
    _setLoading(true);
    await db.delete(categoryTable, id: id);
    categories.removeWhere((item) => item.id == id);
    _setLoading(false);
  }

  Future<Category?> checkCategoryName(String name, {int? excludeId}) async {
    _setLoading(true);

    final res = await db.get(
      categoryTable,
      where: "LOWER(name) = LOWER(?) ${excludeId != null ? 'AND id != ?' : ''}",
      whereArgs: excludeId != null ? [name, excludeId] : [name],
    );

    _setLoading(false);

    if (res.isEmpty) return null;
    return Category.fromMap(res.first);
  }

  Future<void> refresh() async {
    await _loadCategories();
  }
}
