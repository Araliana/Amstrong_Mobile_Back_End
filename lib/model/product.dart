class Product {
  int? id;
  String name;
  String? slug;
  double price;
  double? discountPrice;
  int stock;
  String? img;
  String? description;
  String? createdAt;

  Product({
    this.id,
    required this.name,
    this.slug,
    required this.price,
    this.discountPrice,
    this.stock = 0,
    this.img,
    this.description,
    this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      slug: map['slug'] as String?,
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
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'slug': slug,
      'price': price,
      'discount_price': discountPrice,
      'stock': stock,
      'img': img,
      'description': description,
    };

    if (id != null) map['id'] = id;
    return map;
  }
}
