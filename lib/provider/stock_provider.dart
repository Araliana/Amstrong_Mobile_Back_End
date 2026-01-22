import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/db/sync_manager.dart';
import 'package:flutter_application_1/model/stock.dart';
import 'package:uuid/uuid.dart';

class StockProvider with ChangeNotifier {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final List<Stock> stocks = [];
  final DBHelper db = DBHelper();
  final Tables stockTable = Tables.stock;
  final Tables productTable = Tables.product;
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
            joinType: JoinType.left,
            isList: false,
          ),
        ],
        where: where,
        whereArgs: whereArgs,
        orderBy: "stock.created_at",
        orderType: OrderType.asc, // ASC untuk FIFO (oldest first)
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
            joinType: JoinType.left,
            isList: false,
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

      // Reload stocks
      await loadStocks(productId: productId);

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

      // Reload stocks
      await loadStocks(productId: productId);

      await analytics.logEvent(name: 'edit_stock', parameters: {'id': id});
    } catch (e) {
      debugPrint("Error editing stock: $e");
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> deleteStock(String id, {String? productId}) async {
    _setLoading(true);
    try {
      await db.delete(stockTable, id: id);
      await sync.syncTable(stockTable);

      // Reload stocks
      if (productId != null) {
        await loadStocks(productId: productId);
      } else {
        await loadStocks();
      }

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
      final stock = await getStockById(stockId);
      if (stock == null) throw Exception('Stock not found');

      if (stock.quantity < quantityToReduce) {
        throw Exception('Insufficient stock quantity');
      }

      final newQuantity = stock.quantity - quantityToReduce;

      await db.update(stockTable, id: stockId, data: {'quantity': newQuantity});

      await sync.syncTable(stockTable);

      // Reload stocks
      await loadStocks(productId: stock.productId);

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
