import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/components/index.dart';
import 'package:flutter_application_1/provider/language_provider.dart';
import 'package:flutter_application_1/provider/stock_provider.dart';
import 'card.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<StockProvider>(context, listen: false);
    _loadFuture = provider.loadStocks();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('stock')),
      ),
      body: FutureBuilder(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              provider.isLoading) {
            return buildLoadingState(lang.getText('loading_data'));
          }

          final items = provider.stocks;

          if (items.isEmpty) {
            return buildEmptyState(
              lang.getText('stock'),
              Icons.inventory_2_outlined,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final stock = items[index];
              return StockCard(
                stock: stock,
                provider: provider,
                lang: lang,
              );
            },
          );
        },
      ),
    );
  }
}
