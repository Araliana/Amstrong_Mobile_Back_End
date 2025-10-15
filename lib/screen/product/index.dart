import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/product.dart';
import 'package:image_picker/image_picker.dart';

import '../../db/product.dart';
import '../../utils/index.dart';
import 'package:provider/provider.dart';
import '../../provider/product_provider.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  // Moved DB access to ProductProvider
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // defer loading to provider consumer (or load when screen mounts via provider)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<ProductProvider>(context, listen: false);
      prov.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive breakpoints
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    // Responsive values
    double horizontalPadding = isMobile
        ? 16.0
        : (isTablet ? screenWidth * 0.1 : screenWidth * 0.2);
    double verticalPadding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
    double titleFontSize = isMobile ? 24.0 : (isTablet ? 32.0 : 40.0);
    double bodyFontSize = isMobile ? 14.0 : (isTablet ? 16.0 : 18.0);
    double spacing = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Product',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 8.0),
                Text(
                  'Kami',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 800 : double.infinity,
              ),
              child: Text(
                "Selain menjual bisa membeli kopi siap minum di kedai kopi kami. Kalian juga dapat membeli biji kopi berkualitas dan produk kopi lainnya dari website ini.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: bodyFontSize,
                  height: 1.6,
                  color: Colors.grey[700],
                ),
              ),
            ),
            SizedBox(height: spacing * 1.5),
            if (Provider.of<ProductProvider>(context).loading)
              const Center(child: CircularProgressIndicator()),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _showProductForm(),
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            // Product Grid
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);
                double cardWidth =
                    (constraints.maxWidth - (crossAxisCount - 1) * 16) /
                    crossAxisCount;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
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
                      cardWidth: cardWidth,
                      isMobile: isMobile,
                      onEdit: () => _showProductForm(editProduct: product),
                      onDelete: () => _confirmDelete(product.id!),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _viewProductDetail() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Product Detail'),
          content: const Text(
            'Coffee Beans Arabica 100%\n\nDetail produk akan ditampilkan di sini.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard({
    required Product product,
    required double cardWidth,
    required bool isMobile,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top buttons
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      icon: const Icon(
                        Icons.remove_red_eye_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      onPressed: () => _viewProductDetail(),
                    ),
                    IconButton(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: cardWidth * (isMobile ? 0.75 : 0.65),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: product.img == null
                      ? Icon(
                          Icons.coffee,
                          size: isMobile ? 60 : 80,
                          color: Colors.brown[300],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(6),
                            child: Center(
                              child: SizedBox(
                                width: cardWidth * 0.8,
                                height: cardWidth * 0.8,
                                child: Image.network(
                                  product.img!,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              product.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star,
                color: Colors.orange,
                size: isMobile ? 16 : 18,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Price
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              children: [
                Text(
                  'IDR ${product.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (product.discountPrice != null)
                  Text(
                    'IDR ${product.discountPrice!.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: isMobile ? 12 : 14,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await Provider.of<ProductProvider>(
        context,
        listen: false,
      ).deleteProduct(id);
    }
  }

  Future<void> _showProductForm({Product? editProduct}) async {
    final nameCtl = TextEditingController(text: editProduct?.name ?? '');
    final priceCtl = TextEditingController(
      text: editProduct?.price.toString() ?? '',
    );
    final stockCtl = TextEditingController(
      text: editProduct?.stock.toString() ?? '0',
    );
    final descCtl = TextEditingController(text: editProduct?.description ?? '');
    File? pickedFile;

    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(editProduct == null ? 'Add Product' : 'Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceCtl,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockCtl,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descCtl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final XFile? image = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        pickedFile = File(image.path);
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('Pick Image'),
                  ),
                  const SizedBox(width: 8),
                  if (editProduct?.img != null)
                    Expanded(child: Text('Current: ${editProduct!.img}')),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtl.text.trim();
              final price = double.tryParse(priceCtl.text.trim()) ?? 0.0;
              final stock = int.tryParse(stockCtl.text.trim()) ?? 0;
              final desc = descCtl.text.trim();

              String? imageUrl = editProduct?.img;
              if (pickedFile != null) {
                final uploaded = await uploadFile(pickedFile!);
                if (uploaded != null) imageUrl = uploaded;
              }

              final provider = Provider.of<ProductProvider>(
                context,
                listen: false,
              );

              if (editProduct == null) {
                final newProduct = Product(
                  name: name,
                  price: price,
                  stock: stock,
                  description: desc,
                  img: imageUrl,
                );
                await provider.addProduct(newProduct, imageFile: pickedFile);
              } else {
                final updated = Product(
                  id: editProduct.id,
                  name: name,
                  price: price,
                  stock: stock,
                  description: desc,
                  img: imageUrl,
                );
                await provider.updateProduct(updated, imageFile: pickedFile);
              }

              Navigator.of(c).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
