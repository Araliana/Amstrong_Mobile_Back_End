class Product {
  int? id;
  String name;
  double price;
  String? discountType; // 'percent' or 'flat'
  double? discountValue;
  String? profitType; // 'percent' or 'flat'
  double? profitAmount;
  String? img;
  String? description;
  DateTime? createdAt;

  Product({
    this.id,
    required this.name,
    required this.price,
    this.discountType,
    this.discountValue,
    this.profitType,
    this.profitAmount,
    this.img,
    this.description,
    this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int,
      name: map['name'] as String? ?? '',
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] as double? ?? 0.0),
      discountType: map['discount_type'] as String?,
      discountValue: map['discount_value'] == null
          ? null
          : (map['discount_value'] is int)
          ? (map['discount_value'] as int).toDouble()
          : (map['discount_value'] as double?),
      profitType: map['profit_type'] as String?,
      profitAmount: map['profit_amount'] == null
          ? null
          : (map['profit_amount'] is int)
          ? (map['profit_amount'] as int).toDouble()
          : (map['profit_amount'] as double?),
      img: map['img'] as String?,
      description: map['description'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      'discount_type': discountType,
      'discount_value': discountValue,
      'profit_type': profitType,
      'profit_amount': profitAmount,
      'img': img,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Helper method to calculate final price after discount
  double getFinalPrice() {
    if (discountValue == null || discountValue == 0) {
      return price;
    }

    if (discountType == 'percent') {
      final discount = price * (discountValue! / 100);
      return price - discount;
    } else {
      // flat discount
      final finalPrice = price - discountValue!;
      return finalPrice > 0 ? finalPrice : 0;
    }
  }

  // Helper method to get discount amount
  double getDiscountAmount() {
    if (discountValue == null || discountValue == 0) {
      return 0;
    }

    if (discountType == 'percent') {
      return price * (discountValue! / 100);
    } else {
      return discountValue!;
    }
  }
}
