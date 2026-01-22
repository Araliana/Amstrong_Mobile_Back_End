// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/provider/language_provider.dart';
// import 'package:flutter_application_1/provider/order_provider.dart';
// import 'package:flutter_application_1/provider/product_provider.dart';
// import 'package:flutter_application_1/screen/order/item_input.dart';
// import 'package:flutter_application_1/utils/index.dart';
// import 'package:provider/provider.dart';
// import 'package:go_router/go_router.dart';

// class OrderFormPage extends StatefulWidget {
//   const OrderFormPage({super.key});

//   @override
//   State<OrderFormPage> createState() => _OrderFormPageState();
// }

// class _OrderFormPageState extends State<OrderFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _addressController = TextEditingController();
//   int _currentStep = 0; // 0: Customer Info, 1: Add Items

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       context.read<ProductProvider>().loadProducts();
//       context.read<OrderProvider>().clearCart();
//     });
//   }

//   void _showProductInputSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => const OrderProductInput(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final orderProvider = Provider.of<OrderProvider>(context);
//     final productProvider = Provider.of<ProductProvider>(context);
//     final lang = Provider.of<LanguageProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(lang.getText('add_post')),
//         backgroundColor: Colors.brown,
//         foregroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           // Step Indicator
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             color: Colors.brown[50],
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _stepIcon(0, lang.getText('customer_info')),
//                 const Icon(Icons.arrow_forward, color: Colors.grey),
//                 _stepIcon(1, lang.getText('add_items')),
//               ],
//             ),
//           ),

//           Expanded(
//             child: _currentStep == 0
//                 ? _buildCustomerForm(lang)
//                 : _buildCartList(lang, orderProvider),
//           ),
//         ],
//       ),
//       bottomNavigationBar: _currentStep == 1
//           ? _buildCheckoutBar(lang, orderProvider, productProvider)
//           : null,
//     );
//   }

//   Widget _stepIcon(int step, String title) {
//     bool isActive = _currentStep == step;
//     return Column(
//       children: [
//         CircleAvatar(
//           radius: 12,
//           backgroundColor: isActive ? Colors.brown : Colors.grey,
//           child: Text(
//             '${step + 1}',
//             style: const TextStyle(fontSize: 12, color: Colors.white),
//           ),
//         ),
//         Text(
//           title,
//           style: TextStyle(
//             color: isActive ? Colors.brown : Colors.grey,
//             fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCustomerForm(LanguageProvider lang) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             TextFormField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: lang.getText('customer_name'),
//                 border: const OutlineInputBorder(),
//               ),
//               validator: (val) =>
//                   val!.isEmpty ? lang.getText('error_required') : null,
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: _addressController,
//               decoration: InputDecoration(
//                 labelText: lang.getText('customer_address'),
//                 border: const OutlineInputBorder(),
//               ),
//               validator: (val) =>
//                   val!.isEmpty ? lang.getText('error_required') : null,
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate())
//                     setState(() => _currentStep = 1);
//                 },
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
//                 child: const Text(
//                   'NEXT',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCartList(LanguageProvider lang, OrderProvider provider) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: ElevatedButton.icon(
//             onPressed: () => _showProductInputSheet(context),
//             icon: const Icon(Icons.add),
//             label: Text(lang.getText('add_items')),
//             style: ElevatedButton.styleFrom(
//               minimumSize: const Size(double.infinity, 45),
//             ),
//           ),
//         ),
//         Expanded(
//           child: provider.cart.isEmpty
//               ? Center(child: Text(lang.getText('cart') + " Empty"))
//               : ListView.builder(
//                   itemCount: provider.cart.length,
//                   itemBuilder: (ctx, i) {
//                     final item = provider.cart[i];
//                     return ListTile(
//                       title: Text(item.productName),
//                       subtitle: Text(
//                         '${item.quantity} x ${formatPrice(item.price)}',
//                       ),
//                       trailing: IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () => provider.removeFromCart(item.id),
//                       ),
//                     );
//                   },
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCheckoutBar(
//     LanguageProvider lang,
//     OrderProvider order,
//     ProductProvider product,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             formatPrice(order.totalCartPrice),
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           ElevatedButton(
//             onPressed: order.cart.isEmpty
//                 ? null
//                 : () async {
//                     final success = await order.createOrder(
//                       customerName: _nameController.text,
//                       address: _addressController.text,
//                       productProvider: product,
//                     );
//                     if (success && mounted) {
//                       context.pop();
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text(lang.getText('order_success'))),
//                       );
//                     }
//                   },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
//             child: Text(
//               lang.getText('checkout'),
//               style: const TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
