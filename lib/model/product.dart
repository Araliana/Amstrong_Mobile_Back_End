import 'package:flutter_application_1/model/stock.dart';

class Product {
  String? id;
  String name;
  String? description;
  String? img;
  String? profitType; // 'percent' or 'flat'
  double? profitAmount;
  String? discountType; // 'percent' or 'flat' - OPTIONAL
  double? discountValue; // OPTIONAL
  int quantity; // total quantity dari semua stock
  List<Stock>? stocks; // list of stocks
  DateTime? createdAt;

  Product({
    this.id,
    required this.name,
    this.description,
    this.img,
    this.profitType,
    this.profitAmount,
    this.discountType,
    this.discountValue,
    this.quantity = 0,
    this.stocks,
    this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    // Parse stocks jika ada
    List<Stock>? stocksList;
    if (map['stock'] != null) {
      if (map['stock'] is List) {
        stocksList = (map['stock'] as List)
            .map((e) => Stock.fromMap(e as Map<String, dynamic>))
            .toList();
      }
    }

    return Product(
      id: map['id'] as String?,
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      img: map['img'] as String?,
      profitType: map['profit_type'] as String?,
      profitAmount: map['profit_amount'] != null
          ? (map['profit_amount'] as num).toDouble()
          : null,
      discountType: map['discount_type'] as String?,
      discountValue: map['discount_value'] != null
          ? (map['discount_value'] as num).toDouble()
          : null,
      quantity: (map['quantity'] as int?) ?? 0,
      stocks: stocksList,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  /// Get oldest stock yang masih ada quantity
  Stock? get oldestAvailableStock {
    if (stocks == null || stocks!.isEmpty) return null;

    // Filter stock yang quantity > 0
    final availableStocks = stocks!.where((s) => s.quantity > 0).toList();
    if (availableStocks.isEmpty) return null;

    // Sort by created_at (oldest first)
    availableStocks.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return a.createdAt!.compareTo(b.createdAt!);
    });

    return availableStocks.first;
  }

  /// Calculate current price based on oldest available stock (WITHOUT discount)
  double? get currentPrice {
    final stock = oldestAvailableStock;
    if (stock == null) return null;

    double basePrice = stock.hpp;

    // Apply profit only
    if (profitType != null && profitAmount != null) {
      if (profitType == 'percent') {
        basePrice += (basePrice * profitAmount! / 100);
      } else if (profitType == 'flat') {
        basePrice += profitAmount!;
      }
    }

    return basePrice;
  }

  /// Calculate discounted price (null if no discount)
  double? get discountedPrice {
    if (!hasDiscount) return null;

    final price = currentPrice;
    if (price == null) return null;

    double discountedPrice = price;

    // Apply discount
    if (discountType == 'percent') {
      discountedPrice -= (price * discountValue! / 100);
    } else if (discountType == 'flat') {
      discountedPrice -= discountValue!;
    }

    return discountedPrice;
  }

  /// Get final price (discounted price if available, otherwise current price)
  double? get finalPrice {
    return discountedPrice ?? currentPrice;
  }

  /// Get HPP dari oldest available stock
  double? get currentHPP {
    return oldestAvailableStock?.hpp;
  }

  /// Total quantity dari semua stock yang available
  int get totalAvailableQuantity {
    if (stocks == null || stocks!.isEmpty) return 0;
    return stocks!
        .where((s) => s.quantity > 0)
        .fold(0, (sum, s) => sum + s.quantity);
  }

  // Helper untuk cek apakah ada discount
  bool get hasDiscount => discountType != null && discountValue != null;

  // Helper untuk cek apakah ada profit
  bool get hasProfit => profitType != null && profitAmount != null;

  // Helper untuk cek apakah ada stock
  bool get hasStock => stocks != null && stocks!.isNotEmpty;

  // Helper untuk cek apakah stock available
  bool get isAvailable => totalAvailableQuantity > 0;
}
