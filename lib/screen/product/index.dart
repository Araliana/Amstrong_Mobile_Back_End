import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/product.dart';
import 'package:flutter_application_1/provider/product_provider.dart';
import 'package:flutter_application_1/components/index.dart';
import 'package:flutter_application_1/screen/product/productDetail.dart'
    as detail;
import 'package:flutter_application_1/screen/product/productFormPage.dart';
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
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isMobile = screenWidth < 600;

                    return _buildProductCard(
                      product: product,
                      isMobile: isMobile,
                      onEdit: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductFormPage(editProduct: product),
                          ),
                        );
                        if (result == true) {
                          provider.loadProducts();
                        }
                      },
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Delete Product'),
                            content: Text(
                              'Are you sure you want to delete "${product.name}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && product.id != null) {
                          await provider.deleteProduct(product.id!);
                        }
                      },
                    );
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

  Widget _buildProductCard({
    required Product product,
    required bool isMobile,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withAlpha(10),
            blurRadius: 12,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.brown[50]!, Colors.brown[100]!],
                      ),
                    ),
                    child: product.img == null || product.img!.isEmpty
                        ? Center(
                            child: Icon(
                              Icons.coffee_rounded,
                              size: isMobile ? 60 : 80,
                              color: Colors.brown[300],
                            ),
                          )
                        : Image.network(
                            product.img!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.brown[400],
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                                  child: Icon(
                                    Icons.broken_image_rounded,
                                    size: 50,
                                    color: Colors.brown[300],
                                  ),
                                ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildIconButton(
                            icon: Icons.visibility_outlined,
                            color: Colors.blue[700]!,
                            onPressed: () =>
                                showProductDetail(context, product),
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            color: Colors.grey[300],
                          ),
                          _buildIconButton(
                            icon: Icons.edit_outlined,
                            color: Colors.orange[700]!,
                            onPressed: onEdit,
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            color: Colors.grey[300],
                          ),
                          _buildIconButton(
                            icon: Icons.delete_outline_rounded,
                            color: Colors.red[700]!,
                            onPressed: onDelete,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.brown[900],
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star_rounded,
                          color: Colors.amber[600],
                          size: isMobile ? 14 : 16,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tampilkan profit info
                        if (product.profitType != null &&
                            product.profitValue != null) ...[
                          Row(
                            children: [
                              Text(
                                'Profit: ',
                                style: TextStyle(
                                  color: Colors.brown[700],
                                  fontSize: isMobile ? 11 : 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                product.profitType == 'percent'
                                    ? '${product.profitValue}%'
                                    : 'IDR ${_formatPrice(product.profitValue!)}',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: isMobile ? 12 : 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Text(
                            'No profit set',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: isMobile ? 11 : 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        SizedBox(height: 4),
                        // Tampilkan quantity
                        Text(
                          'Qty: ${product.quantity}',
                          style: TextStyle(
                            color: Colors.brown[600],
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20),
      color: color,
      onPressed: onPressed,
      padding: EdgeInsets.all(8),
      constraints: BoxConstraints(),
      splashRadius: 20,
    );
  }

  void showProductDetail(BuildContext context, Product product) {
    detail.showProductDetail(context, product);
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(price.toInt());
  }
}
