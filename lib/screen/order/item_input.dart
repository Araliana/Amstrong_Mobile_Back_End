// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_application_1/model/product.dart';
// import 'package:flutter_application_1/provider/language_provider.dart';
// import 'package:flutter_application_1/provider/order_provider.dart';
// import 'package:flutter_application_1/provider/product_provider.dart';
// import 'package:provider/provider.dart';

// class OrderProductInput extends StatefulWidget {
//   const OrderProductInput({super.key});

//   @override
//   State<OrderProductInput> createState() => _OrderProductInputState();
// }

// class _OrderProductInputState extends State<OrderProductInput> {
//   Product? _selectedProduct;
//   final _qtyController = TextEditingController();

//   void _handleAdd(BuildContext context) {
//     if (_selectedProduct == null || _qtyController.text.isEmpty) return;

//     final orderProvider = Provider.of<OrderProvider>(context, listen: false);
//     final lang = Provider.of<LanguageProvider>(context, listen: false);
//     int reqQty = int.tryParse(_qtyController.text) ?? 0;

//     if (reqQty <= 0) return;

//     // CEK STOK
//     int status = orderProvider.checkStockAvailability(
//       _selectedProduct!,
//       reqQty,
//     );

//     if (status == 0) {
//       orderProvider.addToCart(
//         product: _selectedProduct!,
//         qty: reqQty,
//         isPreOrder: false,
//       );
//       Navigator.pop(context);
//     } else {
//       // Munculkan Warning
//       showDialog(
//         context: context,
//         builder: (ctx) => AlertDialog(
//           title: Text(lang.getText('stock_warning')),
//           content: Text(
//             "${lang.getText('stock_not_enough')}: ${_selectedProduct!.stock}",
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 if (_selectedProduct!.stock > 0) {
//                   orderProvider.addToCart(
//                     product: _selectedProduct!,
//                     qty: _selectedProduct!.stock,
//                     isPreOrder: false,
//                   );
//                 }
//                 Navigator.pop(ctx);
//                 Navigator.pop(context);
//               },
//               child: Text(lang.getText('btn_use_stock')),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//               onPressed: () {
//                 orderProvider.addToCart(
//                   product: _selectedProduct!,
//                   qty: reqQty,
//                   isPreOrder: true,
//                 );
//                 Navigator.pop(ctx);
//                 Navigator.pop(context);
//               },
//               child: Text(lang.getText('btn_pre_order')),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final products = Provider.of<ProductProvider>(context).products;
//     final lang = Provider.of<LanguageProvider>(context);

//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//         left: 20,
//         right: 20,
//         top: 20,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             lang.getText('add_items'),
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//           const SizedBox(height: 16),
//           DropdownButtonFormField<Product>(
//             value: _selectedProduct,
//             items: products
//                 .map(
//                   (p) => DropdownMenuItem(
//                     value: p,
//                     child: Text("${p.name} (Stock: ${p.stock})"),
//                   ),
//                 )
//                 .toList(),
//             onChanged: (val) => setState(() => _selectedProduct = val),
//             decoration: InputDecoration(
//               labelText: lang.getText('product_name'),
//               border: const OutlineInputBorder(),
//             ),
//           ),
//           const SizedBox(height: 12),
//           TextFormField(
//             controller: _qtyController,
//             keyboardType: TextInputType.number,
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//             decoration: const InputDecoration(
//               labelText: 'Quantity',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: _selectedProduct == null
//                 ? null
//                 : () => _handleAdd(context),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.brown,
//               minimumSize: const Size(double.infinity, 50),
//             ),
//             child: Text(
//               lang.getText('add'),
//               style: const TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
