import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/product.dart';
import 'package:flutter_application_1/screen/product/productDetail.dart';
import 'package:flutter_application_1/screen/product/productFormPage.dart';
import 'package:flutter_application_1/screen/product/productDelete.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../provider/product_provider.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<ProductProvider>(context, listen: false);
      prov.loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    double horizontalPadding = isMobile
        ? 20.0
        : (isTablet ? screenWidth * 0.08 : screenWidth * 0.15);
    double verticalPadding = isMobile ? 20.0 : (isTablet ? 32.0 : 40.0);
    double titleFontSize = isMobile ? 28.0 : (isTablet ? 36.0 : 44.0);
    double bodyFontSize = isMobile ? 14.0 : (isTablet ? 16.0 : 18.0);
    double spacing = isMobile ? 20.0 : (isTablet ? 28.0 : 36.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.brown[50]!, Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Product',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w800,
                          color: Colors.brown[900],
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(width: 12.0),
                      Text(
                        'Kami',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w800,
                          color: Colors.brown[600],
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.brown[600]!, Colors.brown[300]!],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 700 : double.infinity,
                ),
                child: Text(
                  "Selain menjual bisa membeli kopi siap minum di kedai kopi kami. Kalian juga dapat membeli biji kopi berkualitas dan produk kopi lainnya dari website ini.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: bodyFontSize,
                    height: 1.7,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: spacing * 1.5),
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1200 : double.infinity,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Save provider reference before navigation
                        final prov = Provider.of<ProductProvider>(
                          context,
                          listen: false,
                        );

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductFormPage(),
                          ),
                        );

                        if (result == true) {
                          prov.loadProducts();
                        }
                      },
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(
                        isMobile ? 'Add' : 'Add Product',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 24,
                          vertical: isMobile ? 12 : 16,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              if (Provider.of<ProductProvider>(context).isLoading)
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(
                    color: Colors.brown[700],
                    strokeWidth: 3,
                  ),
                ),
              if (!Provider.of<ProductProvider>(context).isLoading)
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);
                    double spacing = isMobile ? 16 : 20;
                    return Container(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 1200 : double.infinity,
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: isMobile ? 0.72 : 0.75,
                        ),
                        itemCount: Provider.of<ProductProvider>(
                          context,
                        ).products.length,
                        itemBuilder: (context, index) {
                          final product = Provider.of<ProductProvider>(
                            context,
                          ).products[index];
                          return _buildProductCard(
                            product: product,
                            isMobile: isMobile,
                            onEdit: () async {
                              final prov = Provider.of<ProductProvider>(
                                context,
                                listen: false,
                              );

                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductFormPage(editProduct: product),
                                ),
                              );

                              if (result == true) {
                                prov.loadProducts();
                              }
                            },
                            onDelete: () {
                              if (product.id != null) {
                                confirmDeleteProduct(context, product.id!);
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              SizedBox(height: 40),
            ],
          ),
        ),
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
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(price.toInt());
  }
}
