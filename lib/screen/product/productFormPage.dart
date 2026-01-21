import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/components/image_picker.dart';
import 'package:flutter_application_1/model/product.dart';
import 'package:provider/provider.dart';
import '../../provider/product_provider.dart';

class ProductFormPage extends StatefulWidget {
  final Product? editProduct;
  const ProductFormPage({super.key, this.editProduct});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtl;
  late TextEditingController _basePriceCtl;
  late TextEditingController _profitValueCtl;
  late TextEditingController _descCtl;

  String _profitType = 'flat';
  double _sellingPreview = 0;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    final p = widget.editProduct;

    _nameCtl = TextEditingController(text: p?.name ?? '');
    _basePriceCtl =
        TextEditingController(text: p?.basePrice.toString() ?? '');
    _profitValueCtl =
        TextEditingController(text: p?.profitValue.toString() ?? '');
    _descCtl = TextEditingController(text: p?.description ?? '');
    _profitType = p?.profitType ?? 'flat';

    _basePriceCtl.addListener(_calculate);
    _profitValueCtl.addListener(_calculate);

    _calculate();
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _basePriceCtl.dispose();
    _profitValueCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  void _calculate() {
    final base = double.tryParse(_basePriceCtl.text) ?? 0;
    final profit = double.tryParse(_profitValueCtl.text) ?? 0;

    setState(() {
      _sellingPreview = _profitType == 'percent'
          ? base + (base * profit / 100)
          : base + profit;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ProductProvider>(context, listen: false);

    if (widget.editProduct == null) {
      await provider.addProduct(
        name: _nameCtl.text.trim(),
        basePrice: double.parse(_basePriceCtl.text),
        profitType: _profitType,
        profitValue: double.parse(_profitValueCtl.text),
        sellingPrice: _sellingPreview,
        description: _descCtl.text.trim(),
        img: null, // handle upload jika perlu
      );
    } else {
      await provider.editProduct(
        id: widget.editProduct!.id,
        name: _nameCtl.text.trim(),
        basePrice: double.parse(_basePriceCtl.text),
        profitType: _profitType,
        profitValue: double.parse(_profitValueCtl.text),
        sellingPrice: _sellingPreview,
        description: _descCtl.text.trim(),
        img: widget.editProduct!.img,
      );
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.editProduct == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ImageSelector(
              initValue: widget.editProduct?.img,
              onChanged: (file) => _pickedImage = file,
            ),

            const SizedBox(height: 16),

            _field(
              controller: _nameCtl,
              label: 'Product Name',
              validator: (v) =>
                  v == null || v.isEmpty ? 'Required' : null,
            ),

            _field(
              controller: _basePriceCtl,
              label: 'Base Price',
              number: true,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Required' : null,
            ),

            DropdownButtonFormField<String>(
              initialValue: _profitType,
              decoration: const InputDecoration(labelText: 'Profit Type'),
              items: const [
                DropdownMenuItem(value: 'flat', child: Text('Flat')),
                DropdownMenuItem(value: 'percent', child: Text('Percent (%)')),
              ],
              onChanged: (v) {
                setState(() => _profitType = v!);
                _calculate();
              },
            ),

            _field(
              controller: _profitValueCtl,
              label: 'Profit Value',
              number: true,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Required' : null,
            ),

            const SizedBox(height: 12),

            Text(
              'Selling Price: IDR ${_sellingPreview.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 16),

            _field(
              controller: _descCtl,
              label: 'Description',
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    bool number = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        inputFormatters:
            number ? [FilteringTextInputFormatter.digitsOnly] : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
