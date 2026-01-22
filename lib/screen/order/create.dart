import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/index.dart';
import 'package:flutter_application_1/model/order.dart';
import 'package:flutter_application_1/model/product.dart';
import 'package:flutter_application_1/provider/order_provider.dart';
import 'package:flutter_application_1/provider/product_provider.dart';
import 'package:flutter_application_1/provider/theme_provider.dart';
import 'package:flutter_application_1/utils/index.dart';
import 'package:provider/provider.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameCtl = TextEditingController();
  final _customerAddressCtl = TextEditingController();

  // List untuk menyimpan controller quantity tiap item agar reaktif
  final List<TextEditingController> _qtyControllers = [];
  final List<CartItem> _cartItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _customerNameCtl.dispose();
    _customerAddressCtl.dispose();
    for (var controller in _qtyControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addCartItem() {
    setState(() {
      final controller = TextEditingController(text: "1");
      // Tambahkan listener untuk update total harga saat angka diketik
      controller.addListener(() {
        final index = _qtyControllers.indexOf(controller);
        if (index != -1) {
          setState(() {
            _cartItems[index].quantity = int.tryParse(controller.text) ?? 0;
          });
        }
      });

      _qtyControllers.add(controller);
      _cartItems.add(
        CartItem(
          productId: '',
          product: Product(
            id: '',
            name: '',
            description: '',
            img: '',
            categoryId: '',
            category: null,
            profitType: 'flat',
            profitAmount: 0,
            quantity: 0,
            stocks: [],
            createdAt: DateTime.now(),
          ),
          quantity: 1,
        ),
      );
    });
  }

  void _removeCartItem(int index) {
    setState(() {
      _qtyControllers[index].dispose();
      _qtyControllers.removeAt(index);
      _cartItems.removeAt(index);
    });
  }

  double get _grandTotal =>
      _cartItems.fold(0, (sum, item) => sum + item.estimatedTotal);

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cartItems.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final success = await context.read<OrderProvider>().createOrder(
        customerName: _customerNameCtl.text.trim(),
        customerAddress: _customerAddressCtl.text.trim(),
        cartItems: _cartItems,
      );

      if (success && mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final isDark = Provider.of<ThemeProvider>(context).getTheme();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Pesanan'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  buildInput(
                    controller: _customerNameCtl,
                    label: 'Nama Pelanggan',
                    icon: Icons.person,
                    isDark: isDark,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  buildInput(
                    controller: _customerAddressCtl,
                    label: 'Alamat',
                    icon: Icons.location_on,
                    isDark: isDark,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Item Produk",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addCartItem,
                        icon: const Icon(Icons.add),
                        label: const Text("Tambah"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_cartItems.isEmpty)
                    const Center(child: Text("Belum ada item")),
                  ..._cartItems.asMap().entries.map((entry) {
                    return _buildProductCard(
                      entry.key,
                      entry.value,
                      productProvider,
                      isDark,
                    );
                  }).toList(),
                ],
              ),
            ),
            _buildBottomBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    int index,
    CartItem item,
    ProductProvider provider,
    bool isDark,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            buildDropdownField(
              label: 'Pilih Produk',
              value: item.productId.isEmpty ? null : item.productId,
              isDark: isDark,
              prefixIcon: Icons.inventory_2,
              items: provider.products
                  .map(
                    (p) => DropdownItem(
                      label: "${p.name} (Stok: ${p.totalAvailableQuantity})",
                      value: p.id,
                      photo: p.img,
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                final p = provider.products.firstWhere((e) => e.id == val);
                setState(() {
                  _cartItems[index].product = p;
                  _cartItems[index].productId = p.id;
                });
              },
            ),
            if (item.productId.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: buildInput(
                      controller: _qtyControllers[index],
                      label: 'Qty',
                      icon: Icons.add_shopping_cart,
                      isDark: isDark,
                      mode: InputMode.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatCurrency(item.estimatedTotal),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeCartItem(index),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
              if (item.quantity > item.product.totalAvailableQuantity)
                const Text(
                  "⚠️ Stok tidak cukup",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Bayar", style: TextStyle(fontSize: 16)),
              Text(
                formatCurrency(_grandTotal),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "SIMPAN ORDER",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
