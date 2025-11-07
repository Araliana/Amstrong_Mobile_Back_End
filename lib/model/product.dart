class Product {
  int? id;
  String name;
  double price;
  double? discountPrice;
  int stock;
  String? img;
  String? description;
  DateTime? createdAt;

  Product({
    this.id,
    required this.name,
    required this.price,
    this.discountPrice,
    this.stock = 0,
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
      discountPrice: map['discount_price'] == null
          ? null
          : (map['discount_price'] is int)
          ? (map['discount_price'] as int).toDouble()
          : (map['discount_price'] as double?),
      stock: (map['stock'] as int?) ?? 0,
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
      'discount_price': discountPrice,
      'stock': stock,
      'img': img,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
