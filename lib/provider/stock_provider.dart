import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/db/sync_manager.dart';
import 'package:flutter_application_1/model/stock.dart';
import 'package:flutter_application_1/model/product.dart';
import 'package:uuid/uuid.dart';

class StockProvider with ChangeNotifier {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final List<Stock> stocks = [];
  final DBHelper db = DBHelper();
  final Tables stockTable = Tables.stock;
  final Tables productTable = Tables.product;
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

  Future<void> loadStocks({String? productId}) async {
    _setLoading(true);
    await sync.syncTable(stockTable);
    await sync.syncTable(productTable);
    await sync.syncTable(categoryTable);

    try {
      String? where;
      List<Object?>? whereArgs;

      if (productId != null) {
        where = "stock.product_id = ?";
        whereArgs = [productId];
      }

      final res = await db.get(
        stockTable,
        joins: [
          Join(
            joinTable: productTable,
            fromKey: 'product_id',
            toKey: 'id',
            isList: false,
          ),
        ],
        where: where,
        whereArgs: whereArgs,
        orderBy: "stock.created_at",
        orderType: OrderType.asc,
      );

      stocks
        ..clear()
        ..addAll(res.map((e) => Stock.fromMap(e)).toList());

      _setLoading(false);
    } catch (e) {
      debugPrint("Error loading stocks: $e");
      _setLoading(false);
      rethrow;
    }

    await analytics.logEvent(
      name: 'load_stocks',
      parameters: {'count': stocks.length},
    );
  }

  Future<Stock?> getStockById(String id) async {
    _setLoading(true);
    await sync.syncTable(stockTable);
    await sync.syncTable(productTable);
    await sync.syncTable(categoryTable);

    try {
      final res = await db.get(
        stockTable,
        joins: [
          Join(
            joinTable: productTable,
            fromKey: 'product_id',
            toKey: 'id',
            joinType: JoinType.left,
            isList: false,
            alias: 'product',
          ),
          Join(
            joinTable: categoryTable,
            fromKey: 'category_id',
            toKey: 'id',
            joinType: JoinType.left,
            isList: false,
            fromTable: productTable,
            alias: 'category',
          ),
        ],
        where: "stock.id = ?",
        whereArgs: [id],
      );

      _setLoading(false);

      if (res.isEmpty) return null;

      await analytics.logEvent(
        name: 'get_stock_detail',
        parameters: {'stock_id': id},
      );

      return Stock.fromMap(res[0]);
    } catch (e) {
      debugPrint("Error getting stock: $e");
      _setLoading(false);
      return null;
    }
  }

  /// Get product with category by ID
  Future<Product?> _getProductById(String productId) async {
    try {
      final res = await db.get(
        productTable,
        joins: [
          Join(
            joinTable: categoryTable,
            fromKey: 'category_id',
            toKey: 'id',
            joinType: JoinType.left,
            isList: false,
            alias: 'category',
          ),
        ],
        where: "product.id = ?",
        whereArgs: [productId],
      );

      if (res.isEmpty) return null;
      return Product.fromMap(res[0]);
    } catch (e) {
      debugPrint("Error getting product: $e");
      return null;
    }
  }

  /// Get oldest stock dengan quantity > 0 untuk product tertentu
  Future<Stock?> getOldestAvailableStock(String productId) async {
    await sync.syncTable(stockTable);

    try {
      final res = await db.get(
        stockTable,
        joins: [
          Join(
            joinTable: productTable,
            fromKey: 'product_id',
            toKey: 'id',
            isList: false,
            alias: 'product',
          ),
          Join(
            joinTable: categoryTable,
            fromKey: 'category_id',
            toKey: 'id',
            isList: false,
            fromTable: productTable,
            alias: 'category',
          ),
        ],
        where: "stock.product_id = ? AND stock.quantity > 0",
        whereArgs: [productId],
        orderBy: "stock.created_at",
        orderType: OrderType.asc, // Oldest first
      );

      if (res.isEmpty) return null;

      return Stock.fromMap(res[0]);
    } catch (e) {
      debugPrint("Error getting oldest stock: $e");
      return null;
    }
  }

  Future<void> addStock({
    required String productId,
    required int quantity,
    required double hpp,
    required double trueProfit,
    required double finalPrice,
  }) async {
    _setLoading(true);
    try {
      final id = uuid.v4();
      await db.insert(stockTable, {
        'id': id,
        'product_id': productId,
        'quantity': quantity,
        'hpp': hpp,
        'true_profit': trueProfit,
        'final_price': finalPrice,
      });

      await sync.syncTable(stockTable);

      // Get product with category
      final product = await _getProductById(productId);
      if (product == null) {
        throw Exception('Product not found');
      }

      // Add to list manually
      stocks.add(
        Stock(
          id: id,
          productId: productId,
          product: product,
          quantity: quantity,
          hpp: hpp,
          trueProfit: trueProfit,
          finalPrice: finalPrice,
          createdAt: DateTime.now(),
        ),
      );

      _setLoading(false);

      await analytics.logEvent(
        name: 'add_stock',
        parameters: {'product_id': productId, 'quantity': quantity, 'hpp': hpp},
      );
    } catch (e) {
      debugPrint("Error adding stock: $e");
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> editStock({
    required String id,
    required String productId,
    required int quantity,
    required double hpp,
    required double trueProfit,
    required double finalPrice,
  }) async {
    _setLoading(true);
    try {
      await db.update(
        stockTable,
        id: id,
        data: {
          'product_id': productId,
          'quantity': quantity,
          'hpp': hpp,
          'true_profit': trueProfit,
          'final_price': finalPrice,
        },
      );

      await sync.syncTable(stockTable);

      // Get product with category
      final product = await _getProductById(productId);
      if (product == null) {
        throw Exception('Product not found');
      }

      // Update list manually
      final index = stocks.indexWhere((item) => item.id == id);
      if (index != -1) {
        final existingStock = stocks[index];
        stocks[index] = Stock(
          id: id,
          productId: productId,
          product: product,
          quantity: quantity,
          hpp: hpp,
          trueProfit: trueProfit,
          finalPrice: finalPrice,
          createdAt: existingStock.createdAt,
        );
      }

      _setLoading(false);

      await analytics.logEvent(name: 'edit_stock', parameters: {'id': id});
    } catch (e) {
      debugPrint("Error editing stock: $e");
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> deleteStock(String id) async {
    _setLoading(true);
    try {
      await db.delete(stockTable, id: id);
      await sync.syncTable(stockTable);

      // Remove from list manually
      stocks.removeWhere((item) => item.id == id);

      _setLoading(false);

      await analytics.logEvent(name: 'delete_stock', parameters: {'id': id});
    } catch (e) {
      debugPrint("Error deleting stock: $e");
      _setLoading(false);
      rethrow;
    }
  }

  /// Reduce stock quantity (untuk transaksi)
  Future<void> reduceStock({
    required String stockId,
    required int quantityToReduce,
  }) async {
    _setLoading(true);
    try {
      final index = stocks.indexWhere((s) => s.id == stockId);
      if (index == -1) throw Exception('Stock not found');

      final stock = stocks[index];

      if (stock.quantity < quantityToReduce) {
        throw Exception('Insufficient stock quantity');
      }

      final newQuantity = stock.quantity - quantityToReduce;

      await db.update(stockTable, id: stockId, data: {'quantity': newQuantity});

      await sync.syncTable(stockTable);

      // Update list manually
      stocks[index] = Stock(
        id: stock.id,
        productId: stock.productId,
        product: stock.product,
        quantity: newQuantity,
        hpp: stock.hpp,
        trueProfit: stock.trueProfit,
        finalPrice: stock.finalPrice,
        createdAt: stock.createdAt,
      );

      _setLoading(false);

      await analytics.logEvent(
        name: 'reduce_stock',
        parameters: {'stock_id': stockId, 'quantity_reduced': quantityToReduce},
      );
    } catch (e) {
      debugPrint("Error reducing stock: $e");
      _setLoading(false);
      rethrow;
    }
  }
}
