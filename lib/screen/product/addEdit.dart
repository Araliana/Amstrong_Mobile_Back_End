import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String? _profitType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.editProduct;

    _nameCtl = TextEditingController(text: p?.name ?? '');
    _profitValueCtl =
        TextEditingController(text: p?.profitValue?.toString() ?? '');
    _descCtl = TextEditingController(text: p?.description ?? '');

    _profitType = p?.profitType;
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

      if (widget.editProduct == null) {
        await provider.addProduct(
          name: _nameCtl.text.trim(),
          description: _descCtl.text.trim(),
          img: imageUrl,
          profitType: _profitType,
          profitValue: double.tryParse(_profitValueCtl.text),
        );
      } else {
        await provider.editProduct(
          id: widget.editProduct!.id,
          name: _nameCtl.text.trim(),
          description: _descCtl.text.trim(),
          img: imageUrl,
          profitType: _profitType,
          profitValue: double.tryParse(_profitValueCtl.text),
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.editProduct == null ? 'Add Product' : 'Edit Product'),
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
            children: [
              ImageSelector(
                initValue: _currentImageUrl,
                onChanged: (file) => setState(() => _pickedFile = file),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtl,
                decoration:
                    const InputDecoration(labelText: 'Product Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _profitType,
                decoration:
                    const InputDecoration(labelText: 'Profit Type'),
                items: const [
                  DropdownMenuItem(value: 'flat', child: Text('Flat')),
                  DropdownMenuItem(value: 'percent', child: Text('Percent')),
                ],
                onChanged: (v) => setState(() => _profitType = v),
              ),
              if (_profitType != null) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _profitValueCtl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration:
                      const InputDecoration(labelText: 'Profit Value'),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtl,
                maxLines: 3,
                decoration:
                    const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                child: Text(
                    _isLoading ? 'Saving...' : 'Save Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
