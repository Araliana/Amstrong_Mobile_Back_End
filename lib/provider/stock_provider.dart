import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/db/sync_manager.dart';
import 'package:flutter_application_1/model/product.dart';
import 'package:flutter_application_1/model/stock.dart';
import 'package:uuid/uuid.dart';

class StockProvider with ChangeNotifier {
  final List<Stock> stocks = [];
  final DBHelper db = DBHelper();
  final SyncManager sync = SyncManager();
  final Tables stockTable = Tables.stock;
  final Tables productTable = Tables.product;
  final uuid = const Uuid();

  bool isLoading = false;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> loadStocks() async {
    _setLoading(true);

    await sync.syncTable(stockTable);

    final stockRes = await db.get(
      stockTable,
      orderBy: 'created_at',
      orderType: OrderType.asc,
    );

    stocks.clear();

    for (final stockMap in stockRes) {
      Product? product;

      final productId = stockMap['product_id'];
      if (productId != null) {
        final productRes = await db.get(
          productTable,
          where: 'id = ?',
          whereArgs: [productId.toString()],
        );

        if (productRes.isNotEmpty) {
          product = Product.fromMap(productRes.first);
        }
      }

      stocks.add(
        Stock.fromMap(
          stockMap,
          product: product,
        ),
      );
    }

    _setLoading(false);
  }

  Future<void> addStock({
    required int productId,
    required int quantity,
    required double hpp,
    required double finalPrice,
    double? trueProfit,
  }) async {
    _setLoading(true);

    await db.insert(stockTable, {
      'id': uuid.v4(),
      'product_id': productId,
      'quantity': quantity,
      'hpp': hpp,
      'true_profit': trueProfit,
      'final_Price': finalPrice,
    });

    await sync.syncTable(stockTable);
    await loadStocks();
  }

  Future<void> updateStockQuantity({
    required Stock oldStock,
    required int newQuantity,
  }) async {
    _setLoading(true);

    await db.update(
      stockTable,
      id: oldStock.id.toString(),
      data: {
        'quantity': newQuantity,
      },
    );

    await sync.syncTable(stockTable);
    await loadStocks();
  }

  Future<void> deleteStock(int id) async {
    _setLoading(true);

    await db.delete(
      stockTable,
      id: id.toString(),
    );

    await sync.syncTable(stockTable);
    await loadStocks();
  }
}
