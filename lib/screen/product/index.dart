import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/product.dart';
import 'package:flutter_application_1/provider/product_provider.dart';
import 'package:flutter_application_1/components/index.dart';
import 'package:flutter_application_1/screen/product/productDetail.dart';
import 'package:flutter_application_1/screen/product/productFormPage.dart';
import 'package:flutter_application_1/screen/product/productDelete.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProductProvider>(context, listen: false);
    _loadFuture = provider.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildLoadingState("Fetching Products...");
          }

          final items = provider.products;

          return items.isEmpty
              ? buildEmptyState("Products", Icons.coffee_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return buildHeader("Products", Icons.storefront);
                    }

                    final product = items[index - 1];

                    return _buildProductCard(context, product, provider);
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductFormPage()),
          );
          if (result == true) {
            provider.loadProducts();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product,
    ProductProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: product.img == null || product.img!.isEmpty
              ? Container(
                  width: 48,
                  height: 48,
                  color: Colors.brown[50],
                  child: Icon(Icons.coffee, color: Colors.brown[300]),
                )
              : Image.network(
                  product.img!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(_priceLabel(product)),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility_outlined),
              onPressed: () => showProductDetail(context, product),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductFormPage(editProduct: product),
                  ),
                );
                if (result == true) {
                  provider.loadProducts();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => confirmDeleteProduct(context, product.id!),
            ),
          ],
        ),
      ),
    );
  }

  String _priceLabel(Product product) {
    final formatter = NumberFormat('#,###', 'id_ID');

    if (product.discountPrice != null && product.discountPrice! > 0) {
      final discounted = product.price - product.discountPrice!;
      return 'IDR ${formatter.format(discounted.toInt())} (Disc)';
    }

    return 'IDR ${formatter.format(product.price.toInt())}';
  }
}
