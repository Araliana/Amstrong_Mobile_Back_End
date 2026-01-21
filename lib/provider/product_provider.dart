import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/model/product.dart';
import 'package:uuid/uuid.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final List<Product> products = [];
  final DBHelper db = DBHelper();
  final Tables productTables = Tables.product;
  final uuid = const Uuid();

  bool isLoading = false;

  void _setLoading(bool value) {
    isLoading = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> loadProducts() async {
    _setLoading(true);
    try {
      final res = await db.get(
        productTables,
        orderBy: "created_at",
        orderType: OrderType.asc,
      );

      print('=== FETCH PRODUCTS ===');
      print('Raw data from DB: $res');
      print('Total rows: ${res.length}');

      products
        ..clear()
        ..addAll(res.map((e) => Product.fromMap(e)).toList());

      print('Products list after mapping: ${products.length} items');
      for (var product in products) {
        print('Product: ${product.name} (ID: ${product.id})');
      }
      print('======================');

      notifyListeners();
    } catch (e) {
      debugPrint("Error loading products: $e");
    } finally {
      _setLoading(false);
    }

    await analytics.logEvent(
      name: 'load_product',
      parameters: {'count': products.length},
    );
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required String? img,
    String? profitType,
    double? profitValue,
  }) async {
    _setLoading(true);
    try {
      const uuid = Uuid();
      await db.insert(productTables, {
        'id': uuid.v4(),
        'name': name,
        'profit_type': profitType,
        'profit_value': profitValue,
        'quantity': 0,
        'description': description,
        'img': img,
      });

      // Reload products dari database untuk memastikan sinkronisasi
      await loadProducts();

      await analytics.logEvent(
        name: 'add_product',
        parameters: {'name': name, 'description': description},
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> editProduct({
    required String name,
    required String description,
    required String? img,
    required String id, // Changed from int to String for UUID
    String? profitType,
    double? profitValue,
    int? quantity,
  }) async {
    _setLoading(true);
    final product = Product.fromMap(
      (await db.get(productTables, where: "id = ?", whereArgs: [id]))[0],
    );

    await db.update(
      productTables,
      id: id, // Already a String, no need for toString()
      data: {
        'name': name,
        'profit_type': profitType,
        'profit_value': profitValue,
        'quantity': quantity ?? product.quantity,
        'description': description,
        'img': img ?? product.img,
      },
    );

    // Reload products dari database untuk memastikan sinkronisasi
    await loadProducts();

    await analytics.logEvent(
      name: 'edit_product',
      parameters: {'name': name, 'description': description},
    );
  }

  Future<void> deleteProduct(String id) async {
    // Changed from int to String for UUID
    _setLoading(true);
    await db.delete(
      productTables,
      id: id,
    ); // Already a String, no need for toString()

    // Reload products dari database untuk memastikan sinkronisasi
    await loadProducts();

    await analytics.logEvent(name: 'delete_product', parameters: {'id': id});
  }
}
