import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late TextEditingController _descCtl;

  File? _pickedFile;
  String? _currentImageUrl;
  String? _profitType = 'none'; // Default: none
  bool _isLoading = false;
  bool _isDark = false; // Sesuaikan dengan theme app Anda

  @override
  void initState() {
    super.initState();
    final p = widget.editProduct;

    _nameCtl = TextEditingController(text: p?.name ?? '');
    _profitValueCtl = TextEditingController(
      text: p?.profitAmount != null ? p!.profitAmount.toString() : '',
    );
    _descCtl = TextEditingController(text: p?.description ?? '');

    _profitType = p?.profitType ?? 'none';
    _currentImageUrl = p?.img;
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _profitValueCtl.dispose();
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

      // Jika profit type = none, set profitAmount ke null
      final profitAmount = _profitType == 'none'
          ? null
          : double.tryParse(_profitValueCtl.text);

      final profitTypeToSave = _profitType == 'none' ? null : _profitType;

      if (widget.editProduct == null) {
        await provider.addProduct(
          name: _nameCtl.text.trim(),
          description: _descCtl.text.trim(),
          img: imageUrl,
          profitType: profitTypeToSave,
          profitAmount: profitAmount,
        );
      } else {
        await provider.editProduct(
          id: widget.editProduct!.id!,
          name: _nameCtl.text.trim(),
          description: _descCtl.text.trim(),
          img: imageUrl,
          profitType: profitTypeToSave,
          profitAmount: profitAmount,
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
    // Detect dark mode
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

              // Profit Type Dropdown
              buildDropdownField(
                label: 'Profit Type',
                value: _profitType,
                prefixIcon: Icons.trending_up,
                isDark: _isDark,
                simpleItems: const ['none', 'flat', 'percent'],
                onChanged: (v) {
                  setState(() {
                    _profitType = v;
                    // Clear profit value jika dikembalikan ke none
                    if (v == 'none') {
                      _profitValueCtl.clear();
                    }
                  });
                },
                validator: (v) => v == null ? 'Required' : null,
              ),

              // Profit Value (hanya muncul jika profit type != none)
              if (_profitType != null && _profitType != 'none') ...[
                const SizedBox(height: 16),
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
