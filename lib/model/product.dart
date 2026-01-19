class Product {
  final String id;
  final String name;
  final double price;
  final double? discountPrice;
  final int stock;
  final String? img;
  final String? description;
  final DateTime? createdAt;

  Product({
    required this.id,
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
      id: map['id'] as String,
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
      'id': id,
      'name': name,
      'price': price,
      'discount_price': discountPrice,
      'stock': stock,
      'img': img,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // --- BAGIAN TAMBAHAN (JEMBATAN) ---
  // Kode di bawah ini ditambahkan agar UI tidak error karena mencari fungsi yang hilang.
  // Tidak merusak data, hanya menghitung data yang sudah ada.

  // 1. Menghitung harga akhir (Jika ada diskon pakai harga diskon, jika tidak pakai harga asli)
  double getFinalPrice() {
    if (discountPrice != null && discountPrice! > 0) {
      return discountPrice!;
    }
    return price;
  }

  // 2. Menghitung nominal potongan (Misal: Harga 10rb, Diskon jadi 8rb, berarti potongan 2rb)
  double getDiscountAmount() {
    if (discountPrice != null && discountPrice! > 0) {
      return price > discountPrice! ? price - discountPrice! : 0.0;
    }
    return 0.0;
  }

  // 3. Menghitung Persentase Diskon (Misal: Potongan 2rb dari 10rb = 20%)
  // UI membutuhkan 'discountValue' (integer), kita hitung otomatis disini.
  int get discountValue {
    if (price <= 0 || discountPrice == null || discountPrice! <= 0) return 0;
    double amount = price - discountPrice!;
    if (amount <= 0) return 0;
    return ((amount / price) * 100).round();
  }
}
