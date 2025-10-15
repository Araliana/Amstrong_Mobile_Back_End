import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/model/product.dart';

import '../db/product.dart';
import '../utils/index.dart';

class ProductProvider extends ChangeNotifier {
  final ProductDB _db = ProductDB();
  final List<Product> _items = [];
  bool _loading = false;

  List<Product> get products => List.unmodifiable(_items);
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final rows = await _db.getAll();
      _items.clear();
      _items.addAll(rows);
    } catch (e) {
      if (kDebugMode) print('ProductProvider.load error: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> addProduct(Product product, {File? imageFile}) async {
    _loading = true;
    notifyListeners();

    try {
      String? imageUrl = product.img;
      if (imageFile != null) {
        final uploaded = await uploadFile(imageFile);
        if (uploaded != null) imageUrl = uploaded;
      }

      final toInsert = Product(
        name: product.name,
        price: product.price,
        stock: product.stock,
        description: product.description,
        img: imageUrl,
      );

      final id = await _db.insert(toInsert);
      toInsert.id = id;
      _items.insert(0, toInsert);
    } catch (e) {
      if (kDebugMode) print('addProduct error: $e');
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> updateProduct(Product product, {File? imageFile}) async {
    _loading = true;
    notifyListeners();
    try {
      String? imageUrl = product.img;
      if (imageFile != null) {
        final uploaded = await uploadFile(imageFile);
        if (uploaded != null) imageUrl = uploaded;
      }

      final updated = Product(
        id: product.id,
        name: product.name,
        price: product.price,
        stock: product.stock,
        description: product.description,
        img: imageUrl,
      );

      await _db.update(updated);

      final idx = _items.indexWhere((e) => e.id == product.id);
      if (idx != -1) _items[idx] = updated;
    } catch (e) {
      if (kDebugMode) print('updateProduct error: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> deleteProduct(int id) async {
    _loading = true;
    notifyListeners();
    try {
      await _db.delete(id);
      _items.removeWhere((e) => e.id == id);
    } catch (e) {
      if (kDebugMode) print('deleteProduct error: $e');
    }
    _loading = false;
    notifyListeners();
  }
}
