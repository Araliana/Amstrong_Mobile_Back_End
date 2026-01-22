import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/model/order_model.dart';
import 'package:flutter_application_1/model/product.dart';
import 'package:flutter_application_1/provider/product_provider.dart';
import 'package:uuid/uuid.dart';

class OrderProvider with ChangeNotifier {
  final DBHelper _db = DBHelper();
  final Uuid _uuid = const Uuid();

  // --- STATE CART (KERANJANG) ---
  List<OrderItem> _cart = [];
  List<OrderItem> get cart => _cart;

  // --- STATE HISTORY ORDERS ---
  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double get totalCartPrice => _cart.fold(0, (sum, item) => sum + item.totalPrice);

  // --- FETCH ORDERS (ADDITION) ---
  // Fungsi ini dipindahkan dari UI ke Provider agar bisa diakses global
  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners(); // Memberitahu UI bahwa sedang loading

    try {
      final data = await _db.get(
        Tables.order,
        orderBy: 'created_at',
        orderType: OrderType.desc,
      );

      _orders = data.map((item) {
        return OrderModel(
          id: item['id'] as String,
          customerName: item['customer_name'] as String,
          customerAddress: item['customer_address'] ?? '-',
          totalPrice: (item['total_price'] as num).toDouble(),
          totalProfit: (item['total_profit'] as num).toDouble(),
          totalHpp: (item['total_hpp'] as num).toDouble(),
          status: item['status'] as String,
          createdAt: item['created_at'] as String,
          isSynced: item['is_synced'] as int? ?? 0,
        );
      }).toList();
    } catch (e) {
      debugPrint("Error fetching orders: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Memberitahu UI data sudah siap
    }
  }

  // --- CEK STOK ---
  int checkStockAvailability(Product product, int reqQty) {
    if (reqQty > product.stock) {
      return 1; // Warning: Stok kurang
    }
    return 0; // Aman
  }

  // --- ADD TO CART ---
  void addToCart({
    required Product product,
    required int qty,
    required bool isPreOrder,
  }) {
    // Asumsi HPP 0 jika tidak ada data modal
    double hppPerItem = 0; 
    
    double totalItemPrice = product.price * qty;
    double totalItemHpp = hppPerItem * qty;
    double totalItemProfit = totalItemPrice - totalItemHpp;

    final index = _cart.indexWhere((item) => item.productId == product.id);

    if (index != -1) {
      final oldItem = _cart[index];
      int newQty = oldItem.quantity + qty;
      
      _cart[index] = OrderItem(
        id: oldItem.id,
        orderId: '',
        productId: product.id,
        stockId: '',
        quantity: newQty,
        totalPrice: product.price * newQty,
        totalProfit: (product.price * newQty) - (hppPerItem * newQty),
        totalHpp: hppPerItem * newQty,
        createdAt: DateTime.now().toIso8601String(),
        productName: product.name,
        isPreOrder: isPreOrder || oldItem.isPreOrder,
      );
    } else {
      _cart.add(OrderItem(
        id: _uuid.v4(),
        orderId: '',
        productId: product.id,
        stockId: '',
        quantity: qty,
        totalPrice: totalItemPrice,
        totalProfit: totalItemProfit,
        totalHpp: totalItemHpp,
        createdAt: DateTime.now().toIso8601String(),
        productName: product.name,
        isPreOrder: isPreOrder,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(String itemId) {
    _cart.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // --- CHECKOUT ---
  Future<bool> createOrder({
    required String customerName,
    required String address,
    required ProductProvider productProvider,
  }) async {
    if (_cart.isEmpty) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final orderId = _uuid.v4();
      final now = DateTime.now().toIso8601String();
      
      double grandTotalProfit = _cart.fold(0, (sum, item) => sum + item.totalProfit);
      double grandTotalHpp = _cart.fold(0, (sum, item) => sum + item.totalHpp);
      bool isPreOrderOrder = _cart.any((item) => item.isPreOrder);

      final order = OrderModel(
        id: orderId,
        customerName: customerName,
        customerAddress: address,
        totalPrice: totalCartPrice,
        totalProfit: grandTotalProfit,
        totalHpp: grandTotalHpp,
        status: isPreOrderOrder ? 'PRE_ORDER' : 'COMPLETED',
        createdAt: now,
        isSynced: 0,
      );

      // [FIX] Menggunakan Tables.order (Enum), bukan String 'orders'
      await _db.insert(Tables.order, order.toMap());

      for (var item in _cart) {
        final finalItem = OrderItem(
          id: item.id,
          orderId: orderId,
          productId: item.productId,
          stockId: item.stockId,
          quantity: item.quantity,
          totalPrice: item.totalPrice,
          totalProfit: item.totalProfit,
          totalHpp: item.totalHpp,
          createdAt: now,
        );

        // [FIX] Menggunakan Tables.orderDetail (Enum)
        await _db.insert(Tables.orderDetail, finalItem.toMap());

        // Update Stock via ProductProvider
        final product = productProvider.products.firstWhere((p) => p.id == item.productId);
        
        int newStock = product.stock - item.quantity;
        if (newStock < 0) newStock = 0; 

        await productProvider.editProduct(
          id: product.id,
          name: product.name,
          price: product.price,
          stock: newStock,
          description: product.description ?? '',
          img: product.img,
          discountPrice: product.discountPrice
        );
      }

      _cart.clear();
      
      // [ADDITION] Refresh list order setelah berhasil checkout
      await fetchOrders();
      
      return true;
    } catch (e) {
      debugPrint("Error create order: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}