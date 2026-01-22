// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/db/db_helper.dart';
// import 'package:flutter_application_1/model/order_model.dart';
// import 'package:flutter_application_1/provider/language_provider.dart';
// import 'package:flutter_application_1/utils/index.dart';
// import 'package:provider/provider.dart';

// class OrderDetailScreen extends StatelessWidget {
//   final OrderModel order;
//   const OrderDetailScreen({super.key, required this.order});

//   Future<List<Map<String, dynamic>>> _loadItems() async {
//     final db = DBHelper();
//     return await db.database.rawQuery(
//       '''
//       SELECT od.*, p.name as product_name 
//       FROM order_detail od
//       LEFT JOIN products p ON od.product_id = p.id
//       WHERE od.order_id = ?
//     ''',
//       [order.id],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final lang = Provider.of<LanguageProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(lang.getText('post_title')),
//         backgroundColor: Colors.brown,
//         foregroundColor: Colors.white,
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _loadItems(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData)
//             return const Center(child: CircularProgressIndicator());
//           final items = snapshot.data!;

//           return ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               ListTile(
//                 title: Text(lang.getText('customer_name')),
//                 subtitle: Text(
//                   order.customerName,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 leading: const Icon(Icons.person),
//               ),
//               const Divider(),
//               ...items.map(
//                 (item) => ListTile(
//                   title: Text(item['product_name'] ?? 'Product'),
//                   subtitle: Text(
//                     "${item['quantity']} x ${formatPrice(item['total_price'] / item['quantity'])}",
//                   ),
//                   trailing: Text(formatPrice(item['total_price'])),
//                 ),
//               ),
//               const Divider(),
//               ListTile(
//                 title: Text(
//                   lang.getText('total'),
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 trailing: Text(
//                   formatPrice(order.totalPrice),
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                     color: Colors.brown,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
