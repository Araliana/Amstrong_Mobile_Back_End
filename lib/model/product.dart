class Product {
<<<<<<< HEAD
  final int id;
  final String name;
  final double basePrice;
  final String? profitType;
  final double? profitValue;
  final double sellingPrice;
  final int quantity;
  final String? img;
  final String? description;
  final DateTime? createdAt;
=======
  String? id; // Changed from int? to String? untuk UUID
  String name;
  String? profitType; // 'percent' or 'flat'
  double? profitValue;
  int quantity; // default 0, tidak diisi di awal
  String? img;
  String? description;
  DateTime? createdAt;
>>>>>>> 8dfd70f4d769de21feeec897811d1e976ff67727

  Product({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.sellingPrice,
    this.profitType,
    this.profitValue,
    this.quantity = 0,
    this.img,
    this.description,
    this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
<<<<<<< HEAD
      id: map['id'],
      name: map['name'],
      basePrice: (map['base_price'] as num).toDouble(),
      sellingPrice: (map['selling_price'] as num).toDouble(),
      profitType: map['profit_type'],
=======
      id: map['id'] as String?, // Changed from int? to String?
      name: map['name'] as String? ?? '',
      profitType: map['profit_type'] as String?,
>>>>>>> 8dfd70f4d769de21feeec897811d1e976ff67727
      profitValue: map['profit_value'] == null
          ? null
          : (map['profit_value'] as num).toDouble(),
      quantity: map['quantity'] ?? 0,
      img: map['img'],
      description: map['description'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'base_price': basePrice,
      'selling_price': sellingPrice,
      'profit_type': profitType,
      'profit_value': profitValue,
      'quantity': quantity,
      'img': img,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
