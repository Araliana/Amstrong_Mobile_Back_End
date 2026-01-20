class Product {
  int? id;
  String name;
  String? profitType; // 'percent' or 'flat'
  double? profitValue;
  int quantity; // default 0, tidak diisi di awal
  String? img;
  String? description;
  DateTime? createdAt;

  Product({
    this.id,
    required this.name,
    this.profitType, // pilih dulu: flat atau percent
    this.profitValue,
    this.quantity = 0, // default 0
    this.img,
    this.description,
    this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int,
      name: map['name'] as String? ?? '',
      profitType: map['profit_type'] as String?,
      profitValue: map['profit_value'] == null
          ? null
          : (map['profit_value'] is int)
          ? (map['profit_value'] as int).toDouble()
          : (map['profit_value'] as double?),
      quantity: map['quantity'] as int? ?? 0,
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
      'profit_type': profitType,
      'profit_value': profitValue,
      'quantity': quantity,
      'img': img,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
