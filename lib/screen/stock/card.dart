import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/stock.dart';
import 'package:flutter_application_1/provider/stock_provider.dart';
import 'package:flutter_application_1/provider/language_provider.dart';

class StockCard extends StatelessWidget {
  final Stock stock;
  final StockProvider provider;
  final LanguageProvider lang;

  const StockCard({
    super.key,
    required this.stock,
    required this.provider,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final qty = stock.quantity;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(stock.productName),
        subtitle: Text(
          '${lang.getText('quantity')}: $qty',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: qty <= 0
                  ? null
                  : () {
                      provider.updateStockQuantity(
                        stock,
                        qty - 1,
                      );
                    },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                provider.updateStockQuantity(
                  stock,
                  qty + 1,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
