class Stock {
<<<<<<< HEAD
  int? id;
  int productId;
=======
  String? id; // Changed from int? to String? untuk UUID
  String productId; // Changed from int to String untuk UUID
  String? productName; // untuk display, dari join
>>>>>>> 8dfd70f4d769de21feeec897811d1e976ff67727
  int quantity;
  double hpp; // Harga Pokok Penjualan
  double trueProfit; // Profit yang dikalkulasi
  double sellingPrice; // Harga jual hasil kalkulasi
  double discount; // Diskon (jika ada adjustment)
  double finalPrice; // Harga akhir setelah adjustment
  DateTime? createdAt;
  DateTime? updatedAt;

  Stock({
    this.id,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.hpp,
    required this.trueProfit,
    required this.sellingPrice,
    this.discount = 0,
    required this.finalPrice,
    this.createdAt,
    this.updatedAt,
  });

  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
<<<<<<< HEAD
      id: map['id'] as int?,
      productId: map['product_id'] as int? ?? 0,
      product: product,
=======
      id: map['id'] as String?, // Changed from int? to String?
      productId: map['product_id'] as String, // Changed from int to String
      productName: map['product_name'] as String?,
>>>>>>> 8dfd70f4d769de21feeec897811d1e976ff67727
      quantity: map['quantity'] as int? ?? 0,
      hpp: map['hpp'] == null
          ? 0.0
          : (map['hpp'] is int)
          ? (map['hpp'] as int).toDouble()
          : (map['hpp'] as double),
      trueProfit: map['true_profit'] == null
          ? 0.0
          : (map['true_profit'] is int)
          ? (map['true_profit'] as int).toDouble()
          : (map['true_profit'] as double),
      sellingPrice: map['selling_price'] == null
          ? 0.0
          : (map['selling_price'] is int)
          ? (map['selling_price'] as int).toDouble()
          : (map['selling_price'] as double),
      discount: map['discount'] == null
          ? 0.0
          : (map['discount'] is int)
          ? (map['discount'] as int).toDouble()
          : (map['discount'] as double),
      finalPrice: map['final_price'] == null
          ? 0.0
          : (map['final_price'] is int)
          ? (map['final_price'] as int).toDouble()
          : (map['final_price'] as double),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
      'hpp': hpp,
      'true_profit': trueProfit,
      'selling_price': sellingPrice,
      'discount': discount,
      'final_price': finalPrice,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper untuk kalkulasi discount percentage
  double get discountPercentage {
    if (sellingPrice == 0) return 0;
    return (discount / sellingPrice) * 100;
  }
}
