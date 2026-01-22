class OrderModel {
  final String id;
  final String customerName;
  final String customerAddress;
  final double totalPrice;
  final double totalProfit; // Sesuaikan dengan DB teman
  final double totalHpp;    // Sesuaikan dengan DB teman
  final String status; 
  final String createdAt;
  final int isSynced;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.customerAddress,
    required this.totalPrice,
    required this.totalProfit, 
    required this.totalHpp,
    required this.status,
    required this.createdAt,
    this.isSynced = 0,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_address': customerAddress,
      'total_price': totalPrice,
      'total_profit': totalProfit,
      'total_hpp': totalHpp,
      'status': status,
      'created_at': createdAt,
      'is_synced': isSynced,
    };
  }

  // Factory dan lainnya bisa disesuaikan...
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String stockId; // Sesuaikan dengan DB teman
  final int quantity;
  final double totalPrice;
  final double totalProfit;
  final double totalHpp;
  final String createdAt;

  // Helper untuk UI (tidak masuk DB order_detail karena tidak ada kolomnya)
  final String productName; 
  final bool isPreOrder; 

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.stockId,
    required this.quantity,
    required this.totalPrice,
    required this.totalProfit,
    required this.totalHpp,
    required this.createdAt,
    this.productName = '',
    this.isPreOrder = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'stock_id': stockId,
      'quantity': quantity,
      'total_price': totalPrice,
      'total_profit': totalProfit,
      'total_hpp': totalHpp,
      'created_at': createdAt,
      'is_synced': 0,
    };
  }
}