import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/model/product.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final List<Product> products = [];
  final DBHelper db = DBHelper();
  final Tables productTables = Tables.product;

  bool isLoading = false;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    _setLoading(true);
    final res = await db.get(
      productTables,
      orderBy: "created_at",
      orderType: OrderType.asc,
    );
    products
      ..clear()
      ..addAll(res.map((e) => Product.fromMap(e)).toList());
    _setLoading(false);

    await analytics.logEvent(
      name: 'load_product',
      parameters: {'count': products.length},
    );
  }

  Future<void> addProduct({
    required String name,
    required double price,
    required String description,
    required String? img,
    String? discountType,
    double? discountValue,
    String? profitType,
    double? profitAmount,
  }) async {
    _setLoading(true);
    await db.insert(productTables, {
      'name': name,
      'price': price,
      'discount_type': discountType,
      'discount_value': discountValue,
      'profit_type': profitType,
      'profit_amount': profitAmount,
      'description': description,
      'img': img,
    });

    // Reload products dari database untuk memastikan sinkronisasi
    await loadProducts();

    await analytics.logEvent(
      name: 'add_product',
      parameters: {'name': name, 'price': price, 'description': description},
    );
  }

  Future<void> editProduct({
    required String name,
    required double price,
    required String description,
    required String? img,
    required int id,
    String? discountType,
    double? discountValue,
    String? profitType,
    double? profitAmount,
  }) async {
    _setLoading(true);
    final product = Product.fromMap(
      (await db.get(productTables, where: "id = ?", whereArgs: [id]))[0],
    );

    await db.update(
      productTables,
      id: id,
      data: {
        'name': name,
        'price': price,
        'discount_type': discountType,
        'discount_value': discountValue,
        'profit_type': profitType,
        'profit_amount': profitAmount,
        'description': description,
        'img': img ?? product.img,
      },
    );

    // Reload products dari database untuk memastikan sinkronisasi
    await loadProducts();

    await analytics.logEvent(
      name: 'edit_product',
      parameters: {'name': name, 'price': price, 'description': description},
    );
  }

  Future<void> deleteProduct(int id) async {
    _setLoading(true);
    await db.delete(productTables, id: id);

    // Reload products dari database untuk memastikan sinkronisasi
    await loadProducts();

    await analytics.logEvent(name: 'delete_product', parameters: {'id': id});
  }
}
