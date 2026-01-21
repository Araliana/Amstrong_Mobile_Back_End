import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/model/order.dart';
import 'package:flutter_application_1/model/stock.dart';
import 'package:flutter_application_1/screen/order/item_input.dart';
import 'package:uuid/uuid.dart';

class OrderProvider with ChangeNotifier {
  final DBHelper db = DBHelper();
  final uuid = const Uuid();

  final Tables orderTable = Tables.order;
  final Tables orderDetailTable = Tables.orderDetail;
  final Tables stockTable = Tables.stock;
  final Tables productTable = Tables.product;

  final List<Order> orders = [];
  bool isLoading = false;

  Future<void> loadOrders() async {
    isLoading = true;
    notifyListeners();

    final res = await db.get(
      orderTable,
      orderBy: 'created_at',
      orderType: OrderType.desc,
    );

    orders
      ..clear()
      ..addAll(res.map((e) => Order.fromMap(e)));

    isLoading = false;
    notifyListeners();
  }

  Future<void> createOrder({
    required List<OrderItemInput> items,
    String? customerName,
    String? customerAddress,
  }) async {
    double totalPrice = 0;
    double totalProfit = 0;
    double totalHpp = 0;

    final orderId = uuid.v4();

    for (final item in items) {
      int remainingQty = item.quantity;

      final stockRes = await db.get(
        stockTable,
        where: 'product_id = ? AND quantity > 0',
        whereArgs: [item.productId],
        orderBy: 'created_at',
        orderType: OrderType.asc,
      );

      final totalStock = stockRes.fold<int>(
        0,
        (sum, s) => sum + (s['quantity'] as int),
      );

      if (totalStock < remainingQty) {
        throw Exception('Stock tidak cukup');
      }

      for (final stockMap in stockRes) {
        if (remainingQty <= 0) break;

        final stock = Stock.fromMap(stockMap);

        final takeQty =
            remainingQty > stock.quantity ? stock.quantity : remainingQty;

        final hpp = stock.hpp * takeQty;
        final price = stock.finalPrice * takeQty;
        final profit = price - hpp;

        await db.insert(orderDetailTable, {
          'id': uuid.v4(),
          'order_id': orderId,
          'product_id': item.productId,
          'stock_id': stock.id,
          'quantity': takeQty,
          'total_price': price,
          'total_profit': profit,
          'total_hpp': hpp,
        });

        await db.update(
          stockTable,
          id: stock.id.toString(),
          data: {'quantity': stock.quantity - takeQty},
        );

        totalPrice += price;
        totalProfit += profit;
        totalHpp += hpp;

        remainingQty -= takeQty;
      }

      final productRes = await db.get(
        productTable,
        where: 'id = ?',
        whereArgs: [item.productId],
      );

      final currentQty = productRes.first['quantity'] as int;

      await db.update(
        productTable,
        id: item.productId.toString(),
        data: {'quantity': currentQty - item.quantity},
      );
    }

    await db.insert(orderTable, {
      'id': orderId,
      'total_price': totalPrice,
      'total_profit': totalProfit,
      'total_hpp': totalHpp,
      'status': 'completed',
      'customer_name': customerName,
      'customer_address': customerAddress,
    });

    await loadOrders();
  }
}
