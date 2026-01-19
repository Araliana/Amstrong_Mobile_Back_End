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
  late TextEditingController _priceCtl;
  late TextEditingController _discountValueCtl;
  late TextEditingController _profitAmountCtl;
  late TextEditingController _descCtl;

  File? _pickedFile;
  String? _currentImageUrl;
  String _discountType = 'percent';
  String _profitType = 'percent';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final product = widget.editProduct;

    _nameCtl = TextEditingController(text: product?.name ?? '');
    _priceCtl = TextEditingController(text: product?.price.toString() ?? '');
    _discountValueCtl = TextEditingController(
      text: product?.discountValue?.toString() ?? '',
    );
    _profitAmountCtl = TextEditingController(
      text: product?.profitAmount?.toString() ?? '',
    );
    _descCtl = TextEditingController(text: product?.description ?? '');

    _discountType = product?.discountType ?? 'percent';
    _profitType = product?.profitType ?? 'percent';
    _currentImageUrl = product?.img;

    // Listen to discount and price changes to update preview
    _discountValueCtl.addListener(() => setState(() {}));
    _priceCtl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _priceCtl.dispose();
    _discountValueCtl.dispose();
    _profitAmountCtl.dispose();
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
          description: _descCtl.text.trim().isEmpty
              ? 'No description'
              : _descCtl.text.trim(),
          img: imageUrl,
          discountType: _discountType,
          discountValue: double.tryParse(_discountValueCtl.text.trim()),
          profitType: _profitType,
          profitAmount: double.tryParse(_profitAmountCtl.text.trim()),
        );
      } else {
        final productId = widget.editProduct?.id;
        if (productId != null) {
          await provider.editProduct(
            id: productId,
            name: _nameCtl.text.trim(),
            price: double.tryParse(_priceCtl.text.trim()) ?? 0.0,
            description: _descCtl.text.trim().isEmpty
                ? 'No description'
                : _descCtl.text.trim(),
            img: imageUrl,
            discountType: _discountType,
            discountValue: double.tryParse(_discountValueCtl.text.trim()),
            profitType: _profitType,
            profitAmount: double.tryParse(_profitAmountCtl.text.trim()),
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

                      // Discount Section
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildTextField(
                              controller: _discountValueCtl,
                              label: 'Discount (Optional)',
                              icon: Icons.discount_outlined,
                              hint: '0',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.brown[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.brown[100]!),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _discountType,
                                  isExpanded: true,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.brown[600],
                                  ),
                                  style: TextStyle(
                                    color: Colors.brown[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'percent',
                                      child: Text('Percent (%)'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'flat',
                                      child: Text('Flat (IDR)'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _discountType = value);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_discountValueCtl.text.isNotEmpty &&
                          double.tryParse(_discountValueCtl.text) != null &&
                          double.parse(_discountValueCtl.text) > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _calculateFinalPrice(),
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      SizedBox(height: 16),

                      // Profit Section
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildTextField(
                              controller: _profitAmountCtl,
                              label: 'Profit (Optional)',
                              icon: Icons.trending_up,
                              hint: '0',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.brown[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.brown[100]!),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _profitType,
                                  isExpanded: true,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.brown[600],
                                  ),
                                  style: TextStyle(
                                    color: Colors.brown[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'percent',
                                      child: Text('Percent (%)'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'flat',
                                      child: Text('Flat (IDR)'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _profitType = value);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
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
            color: Colors.brown.withValues(alpha: 0.1),
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

  String _calculateFinalPrice() {
    final price = double.tryParse(_priceCtl.text) ?? 0;
    final discountValue = double.tryParse(_discountValueCtl.text) ?? 0;

    if (discountValue == 0) return '';

    double finalPrice;
    double discountAmount;

    if (_discountType == 'percent') {
      discountAmount = price * (discountValue / 100);
      finalPrice = price - discountAmount;
    } else {
      discountAmount = discountValue;
      finalPrice = price - discountValue;
    }

    if (finalPrice < 0) {
      return '⚠️ Warning: Discount exceeds price!';
    }

    return 'Discount: IDR ${_formatPrice(discountAmount)} | Final price: IDR ${_formatPrice(finalPrice)}';
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(price.toInt());
  }
}
