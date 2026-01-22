import 'product.dart';

class Stock {
  String id;
  String productId;
  int quantity;
  double hpp;
  double trueProfit;
  double finalPrice;
  Product? product; // Join data from product table
  DateTime createdAt;

  Stock({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.hpp,
    required this.trueProfit,
    required this.finalPrice,
    this.product,
    required this.createdAt,
  });

  factory Stock.fromMap(Map<String, dynamic> map) {
    // Parse product data dari join jika ada
    Product? productData;
    if (map['product'] != null) {
      final prodMap = map['product'] is Map<String, dynamic>
          ? map['product'] as Map<String, dynamic>
          : Map<String, dynamic>.from(map['product'] as Map);
      productData = Product.fromMap(prodMap);
    }

    return Stock(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      quantity: (map['quantity'] as int?) ?? 0,
      hpp: (map['hpp'] as num).toDouble(),
      trueProfit: map['true_profit'] != null
          ? (map['true_profit'] as num).toDouble()
          : 0.0,
      finalPrice: map['final_price'] != null
          ? (map['final_price'] as num).toDouble()
          : 0.0,
      product: productData,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  /// Helper untuk get product name (dari join atau null)
  String get productName => product?.name ?? 'Unknown Product';

  /// Helper untuk cek apakah stock masih available
  bool get isAvailable => quantity > 0;

  bool isActiveStock(List<Stock> allProductStocks) {
    // Filter stocks yang available untuk product ini
    final availableStocks = allProductStocks
        .where((s) => s.productId == productId && s.quantity > 0)
        .toList();

    if (availableStocks.isEmpty) return false;

    // Sort by created_at (oldest first)
    availableStocks.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Cek apakah stock ini adalah yang pertama (oldest)
    return availableStocks.first.id == id;
  }

  /// Calculate current price based on product's profit and discount
  double? get currentPrice {
    if (product == null) return finalPrice;

    double basePrice = hpp;

    // Apply profit
    if (product!.profitType == 'percent') {
      basePrice += (basePrice * product!.profitAmount / 100);
    } else if (product!.profitType == 'flat') {
      basePrice += product!.profitAmount;
    }

    return basePrice;
  }

  /// Calculate discounted price
  double? get discountedPrice {
    if (product == null || !product!.hasDiscount) return null;

    final price = currentPrice;
    if (price == null) return null;

    double discountedPrice = price;

    if (product!.discountType == 'percent') {
      discountedPrice -= (price * product!.discountValue! / 100);
    } else if (product!.discountType == 'flat') {
      discountedPrice -= product!.discountValue!;
    }

    return discountedPrice;
  }

  /// Get final selling price
  double get sellingPrice {
    return finalPrice > 0
        ? finalPrice
        : (discountedPrice ?? currentPrice ?? hpp);
  }

  /// Calculate profit margin
  double get profitMargin {
    final price = sellingPrice;
    if (price <= hpp) return 0;
    return price - hpp;
  }

  /// Calculate profit percentage
  double get profitPercentage {
    if (hpp == 0) return 0;
    return (profitMargin / hpp) * 100;
  }

  /// Total value of this stock (hpp * quantity)
  double get totalValue {
    return hpp * quantity;
  }

  /// Total potential profit from this stock
  double get totalPotentialProfit {
    return profitMargin * quantity;
  }
}
