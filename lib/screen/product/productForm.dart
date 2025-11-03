import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../provider/product_provider.dart';
import '../../utils/index.dart';

Future<void> showProductForm(
  BuildContext context, {
  Product? editProduct,
}) async {
  final nameCtl = TextEditingController(text: editProduct?.name ?? '');
  final priceCtl = TextEditingController(
    text: editProduct?.price.toString() ?? '',
  );
  final stockCtl = TextEditingController(
    text: editProduct?.stock.toString() ?? '0',
  );
  final descCtl = TextEditingController(text: editProduct?.description ?? '');
  File? pickedFile;
  String? currentImagePreview = editProduct?.img;
  final ImagePicker picker = ImagePicker();

  await showDialog(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              editProduct == null
                  ? Icons.add_box_outlined
                  : Icons.edit_outlined,
              color: Colors.brown[700],
            ),
            SizedBox(width: 8),
            Text(
              editProduct == null ? 'Add Product' : 'Edit Product',
              style: TextStyle(
                color: Colors.brown[900],
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(dialogContext).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Preview
                if (pickedFile != null || currentImagePreview != null)
                  Container(
                    width: double.infinity,
                    height: 180,
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.brown[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.brown[200]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: pickedFile != null
                          ? Image.file(pickedFile!, fit: BoxFit.contain)
                          : (currentImagePreview != null
                                ? Image.network(
                                    currentImagePreview,
                                    fit: BoxFit.contain,
                                    errorBuilder: (ctx, error, stackTrace) =>
                                        Center(
                                          child: Icon(
                                            Icons.broken_image_rounded,
                                            size: 60,
                                            color: Colors.brown[300],
                                          ),
                                        ),
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 60,
                                      color: Colors.brown[300],
                                    ),
                                  )),
                    ),
                  ),

                // Image Picker Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setState(() {
                          pickedFile = File(image.path);
                        });
                      }
                    },
                    icon: Icon(Icons.image_outlined, size: 20),
                    label: Text(
                      pickedFile != null
                          ? 'Change Image'
                          : (currentImagePreview != null
                                ? 'Change Image'
                                : 'Pick Image'),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.brown[700],
                      side: BorderSide(color: Colors.brown[300]!),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Form Fields
                _buildTextField(
                  controller: nameCtl,
                  label: 'Product Name',
                  icon: Icons.shopping_bag_outlined,
                  hint: 'Enter product name',
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: priceCtl,
                  label: 'Price',
                  icon: Icons.attach_money_rounded,
                  hint: 'Enter price',
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: stockCtl,
                  label: 'Stock',
                  icon: Icons.inventory_2_outlined,
                  hint: 'Enter stock quantity',
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: descCtl,
                  label: 'Description',
                  icon: Icons.description_outlined,
                  hint: 'Enter product description',
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtl.text.trim();
              final price = double.tryParse(priceCtl.text.trim()) ?? 0.0;
              final stock = int.tryParse(stockCtl.text.trim()) ?? 0;
              final desc = descCtl.text.trim();

              // Save ScaffoldMessenger for later use
              final messenger = ScaffoldMessenger.of(context);

              // Validation
              if (name.isEmpty) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Please enter product name'),
                    backgroundColor: Colors.red[700],
                  ),
                );
                return;
              }

              if (price <= 0) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid price'),
                    backgroundColor: Colors.red[700],
                  ),
                );
                return;
              }

              String? imageUrl = editProduct?.img;
              if (pickedFile != null) {
                final uploaded = await uploadFile(pickedFile!);
                imageUrl = uploaded;
              }

              final provider = Provider.of<ProductProvider>(
                context,
                listen: false,
              );

              // Save variable before closing dialog
              final isNewProduct = editProduct == null;

              if (editProduct == null) {
                await provider.addProduct(
                  name: name,
                  price: price,
                  stock: stock,
                  description: desc,
                  img: imageUrl,
                );
              } else {
                final productId = editProduct.id;
                if (productId != null) {
                  await provider.editProduct(
                    id: productId,
                    name: name,
                    price: price,
                    stock: stock,
                    description: desc,
                    img: imageUrl,
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Product ID is missing'),
                      backgroundColor: Colors.red[700],
                    ),
                  );
                  return;
                }
              }

              Navigator.of(c).pop();

              // Show success message using saved messenger
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    isNewProduct
                        ? 'Product added successfully!'
                        : 'Product updated successfully!',
                  ),
                  backgroundColor: Colors.green[700],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[700],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              editProduct == null ? 'Add' : 'Save',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  String? hint,
  TextInputType? keyboardType,
  int maxLines = 1,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.brown[600], size: 20),
      labelStyle: TextStyle(
        color: Colors.brown[700],
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.brown[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.brown[700]!, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
