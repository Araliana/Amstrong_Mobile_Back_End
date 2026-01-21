class Order {
  final int id;
  final double totalPrice;
  final double totalProfit;
  final double totalHpp;
  final String status;
  final String? customerName;
  final String? customerAddress;
  final DateTime? createdAt;

  Order({
    required this.id,
    required this.totalPrice,
    required this.totalProfit,
    required this.totalHpp,
    required this.status,
    this.customerName,
    this.customerAddress,
    this.createdAt,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      totalPrice: _toDouble(map['total_price']),
      totalProfit: _toDouble(map['total_profit']),
      totalHpp: _toDouble(map['total_hpp']),
      status: map['status'] ?? '',
      customerName: map['customer_name'],
      customerAddress: map['customer_address'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_price': totalPrice,
      'total_profit': totalProfit,
      'total_hpp': totalHpp,
      'status': status,
      'customer_name': customerName,
      'customer_address': customerAddress,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v.toDouble();
    return v as double;
  }
}
