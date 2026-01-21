import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/provider/order_provider.dart';
import 'package:flutter_application_1/provider/product_provider.dart';
import 'package:flutter_application_1/screen/order/item_input.dart';

class OrderFormPage extends StatefulWidget {
  const OrderFormPage({super.key});

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final customerNameCtrl = TextEditingController();
  final customerAddressCtrl = TextEditingController();

  final List<OrderItemInput> items = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<ProductProvider>().loadProducts(),
    );
  }

  void addItem() {
    final products = context.read<ProductProvider>().products;
    if (products.isEmpty) return;

    setState(() {
      items.add(
        OrderItemInput(
          productId: products.first.id, // ✅ int, no !
          quantity: 1,
        ),
      );
    });
  }

  double calculateTotal() {
    final productProvider = context.read<ProductProvider>();
    double total = 0;

    for (final item in items) {
      final product = productProvider.getById(item.productId);
      if (product != null) {
        total += product.sellingPrice * item.quantity;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Order')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            /// CUSTOMER
            TextField(
              controller: customerNameCtrl,
              decoration: const InputDecoration(labelText: 'Customer Name'),
            ),
            TextField(
              controller: customerAddressCtrl,
              decoration: const InputDecoration(labelText: 'Customer Address'),
            ),

            const SizedBox(height: 16),

            /// ITEM LIST
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No items'))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return Card(
                          child: ListTile(
                            title: DropdownButton<int>(
                              value: item.productId,
                              isExpanded: true,
                              items: productProvider.products
                                  .map(
                                    (p) => DropdownMenuItem<int>(
                                      value: p.id,
                                      child: Text(p.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val == null) return;
                                setState(() {
                                  items[index] = OrderItemInput(
                                    productId: val,
                                    quantity: item.quantity,
                                  );
                                });
                              },
                            ),
                            subtitle: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: item.quantity <= 1
                                      ? null
                                      : () {
                                          setState(() {
                                            items[index] = OrderItemInput(
                                              productId: item.productId,
                                              quantity: item.quantity - 1,
                                            );
                                          });
                                        },
                                ),
                                Text(item.quantity.toString()),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      items[index] = OrderItemInput(
                                        productId: item.productId,
                                        quantity: item.quantity + 1,
                                      );
                                    });
                                  },
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() => items.removeAt(index));
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),

            /// TOTAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  calculateTotal().toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: addItem,
                    child: const Text('Add Item'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: items.isEmpty || orderProvider.isLoading
                        ? null
                        : () async {
                            try {
                              await orderProvider.createOrder(
                                items: items,
                                customerName: customerNameCtrl.text,
                                customerAddress: customerAddressCtrl.text,
                              );
                              if (mounted) Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          },
                    child: orderProvider.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add Order'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
