import 'package:flutter_application_1/model/product.dart';

class Stock {
  int? id;
  int productId;
  int quantity;
  double hpp;
  double? trueProfit;
  double finalPrice;
  DateTime? createdAt;
  DateTime? updatedAt;
  int isSynced;
  Product? product;

  Stock({
    this.id,
    required this.productId,
    this.product,
    this.quantity = 0,
    required this.hpp,
    this.trueProfit,
    required this.finalPrice,
    this.createdAt,
    this.updatedAt,
    this.isSynced = 0,
  });

  factory Stock.fromMap(
    Map<String, dynamic> map, {
    Product? product,
  }) {
    return Stock(
      id: map['id'] as int?,
      productId: map['product_id'] as int? ?? 0,
      product: product,
      quantity: map['quantity'] as int? ?? 0,
      hpp: _toDouble(map['hpp']),
      trueProfit: map['true_profit'] != null
          ? _toDouble(map['true_profit'])
          : null,
      finalPrice: _toDouble(map['final_Price']),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      isSynced: map['is_synced'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
      'hpp': hpp,
      'true_profit': trueProfit,
      'final_Price': finalPrice,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_synced': isSynced,
    };
  }

  String get productName => product?.name ?? '-';

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    return value as double;
  }
}
