import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/index.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../model/product.dart';
import '../../provider/product_provider.dart';
import '../../components/image_picker.dart';
import '../../utils/index.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? editProduct;

  const AddEditProductScreen({super.key, this.editProduct});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameCtl;
  late TextEditingController _profitValueCtl;
  late TextEditingController _discountValueCtl;
  late TextEditingController _descCtl;

  File? _pickedFile;
  String? _currentImageUrl;
  String? _profitType = 'flat'; // Default: flat
  String? _discountType = 'none'; // Default: none
  bool _isLoading = false;
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    final p = widget.editProduct;

    _nameCtl = TextEditingController(text: p?.name ?? '');
    _profitValueCtl = TextEditingController(
      text: p?.profitAmount != null ? p!.profitAmount.toString() : '',
    );
    _discountValueCtl = TextEditingController(
      text: p?.discountValue != null ? p!.discountValue.toString() : '',
    );
    _descCtl = TextEditingController(text: p?.description ?? '');

    _profitType = p?.profitType ?? 'flat';
    _discountType = p?.discountType ?? 'none';
    _currentImageUrl = p?.img;
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _profitValueCtl.dispose();
    _discountValueCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<ProductProvider>();

      String? imageUrl = _currentImageUrl;
      if (_pickedFile != null) {
        imageUrl = await uploadFile(_pickedFile!);
      }

      // Profit amount wajib diisi (karena profit type tidak ada none)
      final profitAmount = double.tryParse(_profitValueCtl.text);

      // Discount value hanya diisi jika discount type != none
      final discountValue = _discountType == 'none'
          ? null
          : double.tryParse(_discountValueCtl.text);

      final discountTypeToSave = _discountType == 'none' ? null : _discountType;

      if (widget.editProduct == null) {
        await provider.addProduct(
          name: _nameCtl.text.trim(),
          description: _descCtl.text.trim(),
          img: imageUrl,
          profitType: _profitType,
          profitAmount: profitAmount,
          discountType: discountTypeToSave,
          discountValue: discountValue,
        );
      } else {
        await provider.editProduct(
          id: widget.editProduct!.id!,
          name: _nameCtl.text.trim(),
          description: _descCtl.text.trim(),
          img: imageUrl,
          profitType: _profitType,
          profitAmount: profitAmount,
          discountType: discountTypeToSave,
          discountValue: discountValue,
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editProduct == null ? 'Add Product' : 'Edit Product',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveProduct,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              ImageSelector(
                initValue: _currentImageUrl,
                onChanged: (file) => setState(() => _pickedFile = file),
              ),
              const SizedBox(height: 20),

              // Product Name
              buildInput(
                controller: _nameCtl,
                label: 'Product Name',
                icon: Icons.shopping_bag,
                isDark: _isDark,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Description
              buildInput(
                controller: _descCtl,
                label: 'Description',
                icon: Icons.description,
                isDark: _isDark,
                maxLines: 4,
                minLines: 3,
              ),
              const SizedBox(height: 16),

              // Profit Type Dropdown (flat/percent only)
              buildDropdownField(
                label: 'Profit Type',
                value: _profitType,
                prefixIcon: Icons.trending_up,
                isDark: _isDark,
                simpleItems: const ['flat', 'percent'],
                onChanged: (v) => setState(() => _profitType = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Profit Value (wajib diisi)
              buildInput(
                controller: _profitValueCtl,
                label: 'Profit Value',
                icon: Icons.attach_money,
                isDark: _isDark,
                mode: InputMode.number,
                prefixText: _profitType == 'percent' ? '% ' : null,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Discount Type Dropdown (none/flat/percent)
              buildDropdownField(
                label: 'Discount Type',
                value: _discountType,
                prefixIcon: Icons.discount,
                isDark: _isDark,
                simpleItems: const ['none', 'flat', 'percent'],
                onChanged: (v) {
                  setState(() {
                    _discountType = v;
                    // Clear discount value jika dikembalikan ke none
                    if (v == 'none') {
                      _discountValueCtl.clear();
                    }
                  });
                },
                validator: (v) => v == null ? 'Required' : null,
              ),

              // Discount Value (hanya muncul jika discount type != none)
              if (_discountType != null && _discountType != 'none') ...[
                const SizedBox(height: 16),
                buildInput(
                  controller: _discountValueCtl,
                  label: 'Discount Value',
                  icon: Icons.money_off,
                  isDark: _isDark,
                  mode: InputMode.number,
                  prefixText: _discountType == 'percent' ? '% ' : null,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Invalid number';
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isLoading ? 'Saving...' : 'Save Product',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
