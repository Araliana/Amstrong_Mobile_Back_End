// ignore_for_file: unused_field

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/components/image_picker.dart';
import 'package:flutter_application_1/model/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../provider/product_provider.dart';
import '../../utils/index.dart';

class ProductFormPage extends StatefulWidget {
  final Product? editProduct;

  const ProductFormPage({super.key, this.editProduct});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  late TextEditingController _nameCtl;
  late TextEditingController _profitAmountCtl;
  late TextEditingController _priceCtl;
  late TextEditingController _discountPriceCtl;
  late TextEditingController _stockCtl;
  late TextEditingController _descCtl;

  File? _pickedFile;
  String? _currentImageUrl;
  final String _profitType = 'percent';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final product = widget.editProduct;

    _nameCtl = TextEditingController(text: product?.name ?? '');
    _priceCtl = TextEditingController(text: product?.price.toString() ?? '');
    _discountPriceCtl = TextEditingController(
      text: product?.discountPrice?.toString() ?? '',
    );
    _stockCtl = TextEditingController(text: product?.stock.toString() ?? '0');
    _descCtl = TextEditingController(text: product?.description ?? '');

    _currentImageUrl = product?.img;

    // Listen to discount and price changes to update preview
    _discountPriceCtl.addListener(() => setState(() {}));
    _priceCtl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _priceCtl.dispose();
    _discountPriceCtl.dispose();
    _stockCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final messenger = ScaffoldMessenger.of(context);

      String? imageUrl = _currentImageUrl;
      if (_pickedFile != null) {
        final uploaded = await uploadFile(_pickedFile!);
        imageUrl = uploaded;
      }

      final provider = Provider.of<ProductProvider>(context, listen: false);

      if (widget.editProduct == null) {
        await provider.addProduct(
          name: _nameCtl.text.trim(),
          price: double.tryParse(_priceCtl.text.trim()) ?? 0.0,
          // stock: int.tryParse(_stockCtl.text.trim()) ?? 0,
          description: _descCtl.text.trim().isEmpty
              ? 'No description'
              : _descCtl.text.trim(),
          img: imageUrl,
          discountPrice: double.tryParse(_discountPriceCtl.text.trim()),
        );
      } else {
        final productId = widget.editProduct?.id;
        if (productId != null) {
          await provider.editProduct(
            id: productId,
            name: _nameCtl.text.trim(),
            price: double.tryParse(_priceCtl.text.trim()) ?? 0.0,
            stock: int.tryParse(_stockCtl.text.trim()) ?? 0,
            description: _descCtl.text.trim().isEmpty
                ? 'No description'
                : _descCtl.text.trim(),
            img: imageUrl,
            discountPrice: double.tryParse(_discountPriceCtl.text.trim()),
          );
        } else {
          throw Exception('Product ID is required for editing');
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              widget.editProduct == null
                  ? 'Product added successfully!'
                  : 'Product updated successfully!',
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.editProduct == null ? 'Add Product' : 'Edit Product',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(Icons.check_rounded),
              onPressed: _saveProduct,
              tooltip: 'Save',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Section
                  ImageSelector(
                    initValue: widget.editProduct?.img,
                    onChanged: (val) => setState(() {
                      _pickedFile = val;
                    }),
                  ),
                  SizedBox(height: 24),

                  // Basic Info Card
                  _buildCard(
                    title: 'Basic Information',
                    icon: Icons.info_outline_rounded,
                    children: [
                      _buildTextField(
                        controller: _nameCtl,
                        label: 'Product Name',
                        icon: Icons.shopping_bag_outlined,
                        hint: 'e.g., Arabica Coffee Beans',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _descCtl,
                        label: 'Description',
                        icon: Icons.description_outlined,
                        hint: 'Product description',
                        maxLines: 3,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Pricing Card
                  _buildCard(
                    title: 'Pricing',
                    icon: Icons.attach_money_rounded,
                    children: [
                      _buildTextField(
                        controller: _priceCtl,
                        label: 'Selling Price',
                        icon: Icons.local_offer_outlined,
                        hint: '0',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Price is required';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) <= 0) {
                            return 'Invalid price';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      _buildTextField(
                        controller: _discountPriceCtl,
                        label: 'Discount Amount (Optional)',
                        icon: Icons.discount_outlined,
                        hint: '0',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      if (_discountPriceCtl.text.isNotEmpty &&
                          double.tryParse(_discountPriceCtl.text) != null &&
                          double.parse(_discountPriceCtl.text) > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Final price: IDR ${_formatPrice((double.tryParse(_priceCtl.text) ?? 0) - (double.tryParse(_discountPriceCtl.text) ?? 0))}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Stock Card
                  _buildCard(
                    title: 'Inventory',
                    icon: Icons.inventory_2_outlined,
                    children: [
                      _buildTextField(
                        controller: _stockCtl,
                        label: 'Stock Quantity',
                        icon: Icons.inventory_outlined,
                        hint: '0',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter stock quantity';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveProduct,
                      icon: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(Icons.save_rounded),
                      label: Text(
                        _isLoading
                            ? 'Saving...'
                            : (widget.editProduct == null
                                  ? 'Add Product'
                                  : 'Update Product'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.brown[700], size: 24),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.brown[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    bool readOnly = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      readOnly: readOnly,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.brown[600], size: 20),
        suffixIcon: suffixIcon,
        labelStyle: TextStyle(
          color: Colors.brown[700],
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: readOnly ? Colors.grey[100] : Colors.brown[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.brown[100]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.brown[700]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[300]!, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[700]!, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(price.toInt());
  }
}
