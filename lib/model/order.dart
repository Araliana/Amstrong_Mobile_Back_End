import 'package:flutter_application_1/model/product.dart';

class OrderModel {
  String id;
  String customerName;
  String customerAddress;
  double totalPrice;
  double totalProfit;
  double totalHpp;
  String status;
  DateTime createdAt;
  List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.customerAddress,
    required this.totalPrice,
    required this.totalProfit,
    required this.totalHpp,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    // Parse items jika ada
    List<OrderItem> itemsList = [];
    if (map['order_detail'] != null && map['order_detail'] is List) {
      itemsList = (map['order_detail'] as List)
          .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    return OrderModel(
      id: map['id'] as String? ?? '',
      customerName: map['customer_name'] as String? ?? '',
      customerAddress: map['customer_address'] as String? ?? '',
      totalPrice: map['total_price'] != null
          ? (map['total_price'] as num).toDouble()
          : 0.0,
      totalProfit: map['total_profit'] != null
          ? (map['total_profit'] as num).toDouble()
          : 0.0,
      totalHpp: map['total_hpp'] != null
          ? (map['total_hpp'] as num).toDouble()
          : 0.0,
      status: map['status'] as String? ?? 'PENDING',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      items: itemsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_address': customerAddress,
      'total_price': totalPrice,
      'total_profit': totalProfit,
      'total_hpp': totalHpp,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class OrderItem {
  String id;
  String orderId;
  String productId;
  String stockId;
  int quantity;
  double totalPrice;
  double totalProfit;
  double totalHpp;
  DateTime createdAt;
  Product? product; // For display purposes

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.stockId,
    required this.quantity,
    required this.totalPrice,
    required this.totalProfit,
    required this.totalHpp,
    required this.createdAt,
    this.product,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    // Parse product jika ada dari join
    Product? productObj;
    if (map['product'] != null && map['product'] is Map) {
      productObj = Product.fromMap(map['product'] as Map<String, dynamic>);
    }

    return OrderItem(
      id: map['id'] as String? ?? '',
      orderId: map['order_id'] as String? ?? '',
      productId: map['product_id'] as String? ?? '',
      stockId: map['stock_id'] as String? ?? '',
      quantity: (map['quantity'] as int?) ?? 0,
      totalPrice: map['total_price'] != null
          ? (map['total_price'] as num).toDouble()
          : 0.0,
      totalProfit: map['total_profit'] != null
          ? (map['total_profit'] as num).toDouble()
          : 0.0,
      totalHpp: map['total_hpp'] != null
          ? (map['total_hpp'] as num).toDouble()
          : 0.0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      product: productObj,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'stock_id': stockId,
      'quantity': quantity,
      'total_price': totalPrice,
      'total_profit': totalProfit,
      'total_hpp': totalHpp,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper untuk price per unit
  double get pricePerUnit => quantity > 0 ? totalPrice / quantity : 0;
  double get profitPerUnit => quantity > 0 ? totalProfit / quantity : 0;
  double get hppPerUnit => quantity > 0 ? totalHpp / quantity : 0;
}

// Helper class untuk cart item sebelum checkout
class CartItem {
  String productId;
  Product product;
  int quantity;

  CartItem({
    required this.productId,
    required this.product,
    required this.quantity,
  });

  // Estimated total (bisa berubah saat checkout tergantung stock FIFO)
  double get estimatedTotal => (product.finalPrice ?? 0.0) * quantity;
}
