import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/db/sync_manager.dart';
import 'package:flutter_application_1/model/order.dart';
import 'package:flutter_application_1/model/stock.dart';
import 'package:uuid/uuid.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final List<OrderModel> orders = [];

  final DBHelper db = DBHelper();
  final Tables orderTable = Tables.order;
  final Tables detailTable = Tables.orderDetail;
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

  Future<void> loadOrders() async {
    _setLoading(true);
    await sync.syncTable(orderTable);
    await sync.syncTable(detailTable);
    await sync.syncTable(productTable);
    await sync.syncTable(categoryTable);

    final res = await db.get(
      orderTable,
      joins: [
        Join(
          joinTable: detailTable,
          fromKey: 'id',
          toKey: 'order_id',
          isList: true,
          alias: 'order_detail',
        ),
      ],
      orderBy: "orders.created_at",
      orderType: OrderType.desc,
    );

    orders
      ..clear()
      ..addAll(res.map((e) => OrderModel.fromMap(e)).toList());

    _setLoading(false);

    await analytics.logEvent(
      name: 'load_orders',
      parameters: {'count': orders.length},
    );
  }

  Future<OrderModel?> getOrderById(String id) async {
    _setLoading(true);
    await sync.syncTable(orderTable);
    await sync.syncTable(detailTable);
    await sync.syncTable(productTable);
    await sync.syncTable(categoryTable);

    final res = await db.get(
      orderTable,
      joins: [
        Join(
          joinTable: detailTable,
          fromKey: 'id',
          toKey: 'order_id',
          isList: true,
          alias: 'order_detail',
        ),
      ],
      where: "orders.id = ?",
      whereArgs: [id],
    );

    _setLoading(false);

    if (res.isEmpty) return null;
    return OrderModel.fromMap(res[0]);
  }

  /// Check stock availability untuk cart items
  Future<Map<String, dynamic>> checkStockAvailability(
    List<CartItem> cartItems,
  ) async {
    for (var cartItem in cartItems) {
      final availableStocks = await db.get(
        stockTable,
        where: "product_id = ? AND quantity > 0",
        whereArgs: [cartItem.productId],
        orderBy: "stock.created_at",
        orderType: OrderType.asc,
      );

      int totalAvailable = availableStocks.fold(
        0,
        (sum, s) => sum + (s['quantity'] as int),
      );

      if (totalAvailable < cartItem.quantity) {
        return {
          'available': false,
          'productName': cartItem.product.name,
          'requested': cartItem.quantity,
          'available': totalAvailable,
        };
      }
    }

    return {'available': true};
  }

  /// Create order dengan FIFO stock management
  Future<bool> createOrder({
    required String customerName,
    required String customerAddress,
    required List<CartItem> cartItems,
  }) async {
    if (cartItems.isEmpty) return false;

    _setLoading(true);

    try {
      // Check stock availability first
      final stockCheck = await checkStockAvailability(cartItems);
      if (stockCheck['available'] == false) {
        throw Exception(
          'Stock tidak cukup untuk ${stockCheck['productName']}! '
          'Diminta: ${stockCheck['requested']}, '
          'Tersedia: ${stockCheck['available']}',
        );
      }

      final orderId = uuid.v4();
      final now = DateTime.now();

      double grandTotalHpp = 0;
      double grandTotalProfit = 0;
      double grandTotalPrice = 0;
      List<OrderItem> finalDetails = [];

      // Process FIFO untuk setiap cart item
      for (var cartItem in cartItems) {
        int remainingQty = cartItem.quantity;

        // Get stocks FIFO (oldest first)
        final availableStocks = await db.get(
          stockTable,
          where: "product_id = ? AND quantity > 0",
          whereArgs: [cartItem.productId],
          orderBy: "stock.created_at",
          orderType: OrderType.asc,
        );

        for (var stockMap in availableStocks) {
          if (remainingQty <= 0) break;

          final stock = Stock.fromMap(stockMap);
          int takenQty = stock.quantity >= remainingQty
              ? remainingQty
              : stock.quantity;

          double itemTotalHpp = stock.hpp * takenQty;
          double itemTotalPrice = stock.finalPrice * takenQty;
          double itemTotalProfit = stock.trueProfit * takenQty;

          // Create order detail for this stock batch
          finalDetails.add(
            OrderItem(
              id: uuid.v4(),
              orderId: orderId,
              productId: cartItem.productId,
              stockId: stock.id,
              quantity: takenQty,
              totalPrice: itemTotalPrice,
              totalHpp: itemTotalHpp,
              totalProfit: itemTotalProfit,
              createdAt: now,
              product: cartItem.product,
            ),
          );

          // Update stock quantity
          await db.update(
            stockTable,
            id: stock.id,
            data: {'quantity': stock.quantity - takenQty},
          );

          grandTotalHpp += itemTotalHpp;
          grandTotalPrice += itemTotalPrice;
          grandTotalProfit += itemTotalProfit;
          remainingQty -= takenQty;
        }

        if (remainingQty > 0) {
          throw Exception('Stock tidak cukup untuk ${cartItem.product.name}!');
        }

        // Update product total quantity
        await _updateProductQuantity(cartItem.productId);
      }

      // Insert order header
      await db.insert(orderTable, {
        'id': orderId,
        'customer_name': customerName,
        'customer_address': customerAddress,
        'total_price': grandTotalPrice,
        'total_profit': grandTotalProfit,
        'total_hpp': grandTotalHpp,
        'status': 'COMPLETED',
      });

      // Insert order details
      for (var detail in finalDetails) {
        await db.insert(detailTable, detail.toMap());
      }

      await sync.syncTable(orderTable);
      await sync.syncTable(detailTable);
      await sync.syncTable(stockTable);
      await sync.syncTable(productTable);

      // Add to list manually
      orders.insert(
        0,
        OrderModel(
          id: orderId,
          customerName: customerName,
          customerAddress: customerAddress,
          totalPrice: grandTotalPrice,
          totalProfit: grandTotalProfit,
          totalHpp: grandTotalHpp,
          status: 'COMPLETED',
          createdAt: now,
          items: finalDetails,
        ),
      );

      _setLoading(false);

      await analytics.logEvent(
        name: 'create_order',
        parameters: {
          'total_price': grandTotalPrice,
          'customer': customerName,
          'items_count': cartItems.length,
        },
      );

      return true;
    } catch (e) {
      debugPrint("Error creating order: $e");
      _setLoading(false);
      rethrow;
    }
  }

  /// Update product total quantity from all stocks
  Future<void> _updateProductQuantity(String productId) async {
    final stocks = await db.get(
      stockTable,
      where: "product_id = ?",
      whereArgs: [productId],
    );

    int totalQty = stocks.fold(0, (sum, s) => sum + (s['quantity'] as int));

    await db.update(productTable, id: productId, data: {'quantity': totalQty});
  }

  Future<void> deleteOrder(String id) async {
    _setLoading(true);

    try {
      // Delete order details first
      final details = await db.get(
        detailTable,
        where: "order_id = ?",
        whereArgs: [id],
      );

      for (var detail in details) {
        await db.delete(detailTable, id: detail['id'] as String);
      }

      // Delete order
      await db.delete(orderTable, id: id);

      await sync.syncTable(orderTable);
      await sync.syncTable(detailTable);

      // Remove from list
      orders.removeWhere((order) => order.id == id);

      _setLoading(false);

      await analytics.logEvent(name: 'delete_order', parameters: {'id': id});
    } catch (e) {
      debugPrint("Error deleting order: $e");
      _setLoading(false);
      rethrow;
    }
  }
}
