class Product {
  final String id;
  final String name;
  final String description;
  final String img;
  final double currentPrice;
  final String profitType;
  final double profitAmount;
  final String? discountType;
  final double? discountValue;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.img,
    required this.currentPrice,
    required this.profitType,
    required this.profitAmount,
    this.discountType,
    this.discountValue,
    this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      description: map['description'] as String,
      img: map['img'] as String,
      currentPrice: map['current_price'] is int
          ? (map['current_price'] as int).toDouble()
          : (map['current_price'] as double),
      profitType: map['profit_type'] as String,
      profitAmount: (map['profit_amount'] is int)
          ? (map['profit_amount'] as int).toDouble()
          : (map['profit_amount'] as double),
      discountType: map['discount_type'] as String?,
      discountValue: map['discount_value'] == null
          ? null
          : (map['discount_value'] is int)
          ? (map['discount_value'] as int).toDouble()
          : (map['discount_value'] as double?),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'img': img,
      'current_price': currentPrice,
      'profit_type': profitType,
      'profit_amount': profitAmount,
      'discount_type': discountType,
      'discount_value': discountValue,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
