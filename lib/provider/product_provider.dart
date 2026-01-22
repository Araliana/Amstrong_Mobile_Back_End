import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/db/sync_manager.dart';
import 'package:flutter_application_1/model/product.dart';
import 'package:uuid/uuid.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final List<Product> products = [];
  final DBHelper db = DBHelper();
  final Tables productTable = Tables.product;
  final Tables stockTable = Tables.stock;
  final Tables categoryTable = Tables.productType;
  final uuid = const Uuid();
  final sync = SyncManager();

  bool isLoading = false;

  void _setLoading(bool value) {
    isLoading = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> loadProducts() async {
    _setLoading(true);
    await sync.syncTable(productTable);
    await sync.syncTable(stockTable);
    await sync.syncTable(categoryTable);

    final res = await db.get(
      productTable,
      joins: [
        Join(
          joinTable: stockTable,
          fromKey: "id",
          toKey: "product_id",
          isList: true,
          joinType: JoinType.left,
        ),
        Join(
          joinTable: categoryTable,
          fromKey: "category_id",
          toKey: "id",
          isList: false,
          alias: "category",
        ),
      ],
      orderBy: "product.created_at",
      orderType: OrderType.desc,
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

  Future<Product?> getProductById(String id) async {
    _setLoading(true);
    await sync.syncTable(productTable);
    await sync.syncTable(stockTable);
    await sync.syncTable(categoryTable);

    final res = await db.get(
      productTable,
      joins: [
        Join(
          joinTable: stockTable,
          fromKey: "id",
          toKey: "product_id",
          isList: true,
        ),
        Join(
          joinTable: categoryTable,
          fromKey: "category_id",
          toKey: "id",
          isList: false,
        ),
      ],
      where: "product.id = ?",
      whereArgs: [id],
    );

    _setLoading(false);

    if (res.isEmpty) return null;

    await analytics.logEvent(
      name: 'get_product_detail',
      parameters: {'product_id': id},
    );

    return Product.fromMap(res[0]);
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required String img,
    required String categoryId,
    required String profitType,
    required double profitAmount,
    String? discountType,
    double? discountValue,
  }) async {
    _setLoading(true);
    try {
      final id = uuid.v4();
      await db.insert(productTable, {
        'id': id,
        'name': name,
        'description': description,
        'img': img,
        'category_id': categoryId,
        'profit_type': profitType,
        'profit_amount': profitAmount,
        'discount_type': discountType,
        'discount_value': discountValue,
        'quantity': 0,
      });

      await sync.syncTable(productTable);
      await loadProducts();

      _setLoading(false);

      await analytics.logEvent(
        name: 'add_product',
        parameters: {
          'name': name,
          'category_id': categoryId,
          'profit_type': profitType,
          'has_discount': (discountType != null).toString(),
        },
      );
    } catch (e) {
      debugPrint('Error adding product: $e');
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> editProduct({
    required String id,
    required String name,
    required String description,
    required String img,
    required String categoryId,
    required String profitType,
    required double profitAmount,
    String? discountType,
    double? discountValue,
  }) async {
    _setLoading(true);
    try {
      await db.update(
        productTable,
        id: id,
        data: {
          'name': name,
          'description': description,
          'img': img,
          'category_id': categoryId,
          'profit_type': profitType,
          'profit_amount': profitAmount,
          'discount_type': discountType,
          'discount_value': discountValue,
        },
      );

      await sync.syncTable(productTable);
      await loadProducts(); // Reload to get complete data with category

      _setLoading(false);

      await analytics.logEvent(
        name: 'edit_product',
        parameters: {
          'id': id,
          'name': name,
          'category_id': categoryId,
          'profit_type': profitType,
          'has_discount': (discountType != null).toString(),
        },
      );
    } catch (e) {
      debugPrint('Error editing product: $e');
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    _setLoading(true);
    await db.delete(productTable, id: id);
    await sync.syncTable(productTable);
    products.removeWhere((item) => item.id == id);
    _setLoading(false);

    await analytics.logEvent(name: 'delete_product', parameters: {'id': id});
  }
}
