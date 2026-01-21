import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/model/stock.dart';
import 'package:flutter_application_1/model/product.dart';
import 'package:uuid/uuid.dart';

class StockProvider with ChangeNotifier {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final List<Stock> stocks = [];
  final DBHelper db = DBHelper();
  final Tables stockTables = Tables.stock;
  final uuid = const Uuid();

  bool isLoading = false;

  void _setLoading(bool value) {
    isLoading = value;
    // Delay notifyListeners sampai frame berikutnya untuk avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Helper: Kalkulasi selling price berdasarkan HPP dan profit product
  Map<String, double> calculatePrices({
    required double hpp,
    required Product product,
    double? customFinalPrice,
  }) {
    double profit = 0;
    double sellingPrice = hpp;

    // Kalkulasi profit berdasarkan tipe
    if (product.profitType != null && product.profitValue != null) {
      if (product.profitType == 'percent') {
        profit = hpp * (product.profitValue! / 100);
      } else if (product.profitType == 'flat') {
        profit = product.profitValue!;
      }
    }

    sellingPrice = hpp + profit;

    // Final price bisa di-adjust
    double finalPrice = customFinalPrice ?? sellingPrice;

    // Kalkulasi discount
    double discount = sellingPrice - finalPrice;
    if (discount < 0) discount = 0; // Tidak boleh negatif

    return {
      'profit': profit,
      'sellingPrice': sellingPrice,
      'discount': discount,
      'finalPrice': finalPrice,
    };
  }

  Future<void> loadStocks({int? productId}) async {
    _setLoading(true);
    try {
      String? where;
      List<Object?>? whereArgs;

      if (productId != null) {
        where = "stock.product_id = ?";
        whereArgs = [productId.toString()];
      }

      final res = await db.get(
        stockTables,
        joins: [
          Join(
            joinTable: Tables.product,
            fromKey: 'product_id',
            toKey: 'id',
            joinType: JoinType.left,
            isList: false,
          ),
        ],
        where: where,
        whereArgs: whereArgs,
        orderBy: "stock.created_at",
        orderType: OrderType.desc,
      );

      print('=== FETCH STOCKS ===');
      print('Raw data from DB: $res');
      print('Total rows: ${res.length}');

      stocks
        ..clear()
        ..addAll(
          res.map((e) {
            // Ambil product name dari join
            // Convert Map<dynamic, dynamic> to Map<String, dynamic>
            final productData = e['product'] != null
                ? Map<String, dynamic>.from(e['product'] as Map)
                : null;
            final productName = productData?['name'] as String?;

            return Stock.fromMap({...e, 'product_name': productName});
          }).toList(),
        );

      print('Stocks list after mapping: ${stocks.length} items');
      for (var stock in stocks) {
        print(
          'Stock: Product ${stock.productName} - Qty: ${stock.quantity} (ID: ${stock.id})',
        );
      }
      print('====================');
    } catch (e) {
      debugPrint("Error loading stocks: $e");
    } finally {
      _setLoading(false);
    }

    await analytics.logEvent(
      name: 'load_stocks',
      parameters: {'count': stocks.length},
    );
  }

  Future<void> addStock({
    required String productId, // Changed from int to String for UUID
    required int quantity,
    required double hpp,
    required double trueProfit,
    required double sellingPrice,
    required double discount,
    required double finalPrice,
  }) async {
    _setLoading(true);
    try {
      await db.insert(stockTables, {
        'id': uuid.v4(),
        'product_id': productId, // Already a String, no need for toString()
        'quantity': quantity,
        'hpp': hpp,
        'true_profit': trueProfit,
        'selling_price': sellingPrice,
        'discount': discount,
        'final_price': finalPrice,
      });

      // Reload stocks dari database
      await loadStocks();

      // Force notify listeners untuk update UI
      notifyListeners();

      await analytics.logEvent(
        name: 'add_stock',
        parameters: {'product_id': productId, 'quantity': quantity, 'hpp': hpp},
      );
    } catch (e) {
      debugPrint("Error adding stock: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> editStock({
    required String id, // Changed from int to String for UUID
    required String productId, // Changed from int to String for UUID
    required int quantity,
    required double hpp,
    required double trueProfit,
    required double sellingPrice,
    required double discount,
    required double finalPrice,
  }) async {
    _setLoading(true);
    try {
      await db.update(
        stockTables,
        id: id.toString(),
        data: {
          'product_id': productId.toString(),
          'quantity': quantity,
          'hpp': hpp,
          'true_profit': trueProfit,
          'selling_price': sellingPrice,
          'discount': discount,
          'final_price': finalPrice,
        },
      );

      // Reload stocks dari database
      await loadStocks();

      // Force notify listeners untuk update UI
      notifyListeners();

      await analytics.logEvent(name: 'edit_stock', parameters: {'id': id});
    } catch (e) {
      debugPrint("Error editing stock: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteStock(String id) async {
    _setLoading(true);
    try {
      await db.delete(
        stockTables,
        id: id,
      ); // Already a String, no need for toString()

      await loadStocks();

      notifyListeners();

      await analytics.logEvent(name: 'delete_stock', parameters: {'id': id});
    } catch (e) {
      debugPrint("Error deleting stock: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
