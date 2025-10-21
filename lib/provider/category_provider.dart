import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/model/category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CategoryProvider extends ChangeNotifier {
  static const String _key = 'categories';
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  CategoryProvider() {
    loadCategories();
  }

  Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    _categories = data.map((e) => Category.fromMap(jsonDecode(e))).toList();
    notifyListeners();
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _categories.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_key, data);
  }

  Future<void> addCategory(String name) async {
    final newCategory = Category(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      createdAt: DateTime.now(),
    );
    _categories.add(newCategory);
    await _saveCategories();
    notifyListeners();
  }

  Future<void> removeCategory(int id) async {
    _categories.removeWhere((cat) => cat.id == id);
    await _saveCategories();
    notifyListeners();
  }
}
