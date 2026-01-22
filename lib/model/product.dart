import 'package:flutter_application_1/model/category.dart';
import 'package:flutter_application_1/model/stock.dart';

class Product {
  String id;
  String name;
  String description;
  String img;
  final String categoryId;
  final Category? category;
  String profitType;
  double profitAmount;
  String? discountType;
  double? discountValue;
  int quantity;
  List<Stock> stocks;
  DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.img,
    required this.categoryId,
    required this.category,
    required this.profitType,
    required this.profitAmount,
    this.discountType,
    this.discountValue,
    required this.quantity,
    required this.stocks,
    required this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    // Parse stocks jika ada
    List<Stock> stocksList = [];
    if (map['stock'] != null && map['stock'] is List) {
      stocksList = (map['stock'] as List)
          .map((e) => Stock.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    return Product(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      img: map['img'] as String? ?? '',
      category: map['category'] != null
          ? Category.fromMap((map['category'] as Map).cast<String, dynamic>())
          : null,
      categoryId: map['category_id'] as String? ?? '',
      profitType: map['profit_type'] as String? ?? 'flat',
      profitAmount: map['profit_amount'] != null
          ? (map['profit_amount'] as num).toDouble()
          : 0.0,
      discountType: map['discount_type'] as String?,
      discountValue: map['discount_value'] != null
          ? (map['discount_value'] as num).toDouble()
          : null,
      quantity: (map['quantity'] as int?) ?? 0,
      stocks: stocksList,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  /// Get oldest stock yang masih ada quantity
  Stock? get oldestAvailableStock {
    if (stocks.isEmpty) return null;

    // Filter stock yang quantity > 0
    final availableStocks = stocks.where((s) => s.quantity > 0).toList();
    if (availableStocks.isEmpty) return null;

    // Sort by created_at (oldest first)
    availableStocks.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return availableStocks.first;
  }

  /// Calculate current price based on oldest available stock (WITHOUT discount)
  double? get currentPrice {
    final stock = oldestAvailableStock;
    if (stock == null) return null;

    double basePrice = stock.hpp;

    // Apply profit (ALWAYS present)
    if (profitType == 'percent') {
      basePrice += (basePrice * profitAmount / 100);
    } else if (profitType == 'flat') {
      basePrice += profitAmount;
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
    if (stocks.isEmpty) return 0;
    return stocks
        .where((s) => s.quantity > 0)
        .fold(0, (sum, s) => sum + s.quantity);
  }

  // Helper untuk cek apakah ada discount
  bool get hasDiscount => discountType != null && discountValue != null;

  bool get hasProfit => profitAmount > 0;

  bool get hasStock => stocks.isNotEmpty;

  bool get isAvailable => totalAvailableQuantity > 0;
}
