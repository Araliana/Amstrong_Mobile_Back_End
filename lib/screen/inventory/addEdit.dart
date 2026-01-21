import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/product.dart';
import 'package:flutter_application_1/model/stock.dart';
import 'package:flutter_application_1/provider/product_provider.dart';
import 'package:flutter_application_1/provider/stock_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddEditStockScreen extends StatefulWidget {
  final Stock? editStock;

  const AddEditStockScreen({super.key, this.editStock});

  @override
  State<AddEditStockScreen> createState() => _AddEditStockScreenState();
}

class _AddEditStockScreenState extends State<AddEditStockScreen> {
  final _formKey = GlobalKey<FormState>();

  Product? _selectedProduct;
  final _hppController = TextEditingController();
  final _quantityController = TextEditingController();
  final _finalPriceController = TextEditingController();

  double _calculatedProfit = 0;
  double _calculatedSellingPrice = 0;
  double _calculatedDiscount = 0;

  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Listen to HPP changes for auto-calculation
    _hppController.addListener(_recalculatePrices);
    _finalPriceController.addListener(_recalculateDiscount);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load products only once
    if (!_isInitialized) {
      _isInitialized = true;
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      productProvider.loadProducts().then((_) {
        // If editing, populate fields after products loaded
        if (widget.editStock != null && mounted) {
          _populateEditData();
        }
      });
    }
  }

  void _populateEditData() {
    final stock = widget.editStock!;
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    _selectedProduct = productProvider.products.firstWhere(
      (p) => p.id == stock.productId,
      orElse: () => productProvider.products.first,
    );

    _hppController.text = stock.hpp.toString();
    _quantityController.text = stock.quantity.toString();
    _finalPriceController.text = stock.finalPrice.toString();

    _recalculatePrices();
  }

  void _recalculatePrices() {
    if (_selectedProduct == null || _hppController.text.isEmpty) {
      setState(() {
        _calculatedProfit = 0;
        _calculatedSellingPrice = 0;
        _calculatedDiscount = 0;
      });
      return;
    }

    final hpp = double.tryParse(_hppController.text) ?? 0;
    final stockProvider = Provider.of<StockProvider>(context, listen: false);

    final prices = stockProvider.calculatePrices(
      hpp: hpp,
      product: _selectedProduct!,
    );

    setState(() {
      _calculatedProfit = prices['profit']!;
      _calculatedSellingPrice = prices['sellingPrice']!;
    });

    _recalculateDiscount();
  }

  void _recalculateDiscount() {
    if (_finalPriceController.text.isEmpty) return;

    final finalPrice = double.tryParse(_finalPriceController.text) ?? 0;
    setState(() {
      _calculatedDiscount = _calculatedSellingPrice - finalPrice;
      if (_calculatedDiscount < 0) _calculatedDiscount = 0;
    });
  }

  Future<void> _saveStock() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih product terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final stockProvider = Provider.of<StockProvider>(context, listen: false);
      final hpp = double.parse(_hppController.text);
      final quantity = int.parse(_quantityController.text);
      final finalPrice = _finalPriceController.text.isEmpty
          ? _calculatedSellingPrice
          : double.parse(_finalPriceController.text);

      if (widget.editStock == null) {
        // Add new stock
        await stockProvider.addStock(
          productId: _selectedProduct!.id!,
          quantity: quantity,
          hpp: hpp,
          trueProfit: _calculatedProfit,
          sellingPrice: _calculatedSellingPrice,
          discount: _calculatedDiscount,
          finalPrice: finalPrice,
        );
      } else {
        // Edit existing stock
        await stockProvider.editStock(
          id: widget.editStock!.id!,
          productId: _selectedProduct!.id!,
          quantity: quantity,
          hpp: hpp,
          trueProfit: _calculatedProfit,
          sellingPrice: _calculatedSellingPrice,
          discount: _calculatedDiscount,
          finalPrice: finalPrice,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.editStock == null
                  ? 'Stock berhasil ditambahkan'
                  : 'Stock berhasil diupdate',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _hppController.dispose();
    _quantityController.dispose();
    _finalPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editStock == null ? 'Tambah Stock' : 'Edit Stock'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product Selection
                    _buildSectionTitle('1. Pilih Product'),
                    const SizedBox(height: 8),
                    productProvider.products.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange[700],
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Belum ada product. Silakan tambahkan product terlebih dahulu.',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : DropdownButtonFormField<Product>(
                            value: _selectedProduct,
                            decoration: _inputDecoration('Product'),
                            isExpanded: true,
                            items: productProvider.products.map((product) {
                              return DropdownMenuItem(
                                value: product,
                                child: Text(product.name),
                              );
                            }).toList(),
                            onChanged: (product) {
                              setState(() {
                                _selectedProduct = product;
                                _recalculatePrices();
                              });
                            },
                            validator: (value) {
                              if (value == null) return 'Product harus dipilih';
                              return null;
                            },
                          ),

                    if (_selectedProduct != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoCard(
                        'Profit Setting: ${_selectedProduct!.profitType ?? 'Tidak ada'} - '
                        '${_selectedProduct!.profitValue != null ? (_selectedProduct!.profitType == 'percent' ? '${_selectedProduct!.profitValue}%' : 'IDR ${_formatPrice(_selectedProduct!.profitValue!)}') : '-'}',
                        Colors.blue,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // HPP Input
                    _buildSectionTitle('2. Input HPP (Harga Pokok Penjualan)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _hppController,
                      decoration: _inputDecoration('HPP'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'HPP harus diisi';
                        }
                        final hpp = double.tryParse(value);
                        if (hpp == null || hpp <= 0) {
                          return 'HPP harus lebih dari 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Calculated Values
                    _buildSectionTitle('3. Kalkulasi Otomatis'),
                    const SizedBox(height: 8),
                    _buildCalculatedField(
                      'Profit',
                      _calculatedProfit,
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _buildCalculatedField(
                      'Harga Jual',
                      _calculatedSellingPrice,
                      Colors.blue,
                    ),

                    const SizedBox(height: 24),

                    // Final Price Adjustment
                    _buildSectionTitle('4. Adjust Harga Akhir (Opsional)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _finalPriceController,
                      decoration: _inputDecoration('Harga Akhir'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        // Optional field - hanya validate jika diisi
                        if (value != null && value.isNotEmpty) {
                          final price = double.tryParse(value);
                          if (price == null || price <= 0) {
                            return 'Harga akhir harus lebih dari 0';
                          }
                        }
                        return null;
                      },
                    ),

                    if (_calculatedDiscount > 0) ...[
                      const SizedBox(height: 8),
                      _buildInfoCard(
                        'Diskon: IDR ${_formatPrice(_calculatedDiscount)} '
                        '(${(_calculatedDiscount / _calculatedSellingPrice * 100).toStringAsFixed(1)}%)',
                        Colors.red,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Quantity
                    _buildSectionTitle('5. Jumlah Stock'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _quantityController,
                      decoration: _inputDecoration('Quantity'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Quantity harus diisi';
                        }
                        final qty = int.tryParse(value);
                        if (qty == null || qty <= 0) {
                          return 'Quantity harus lebih dari 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveStock,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.editStock == null
                                  ? 'Simpan Stock'
                                  : 'Update Stock',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.brown[800],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.brown, width: 2),
      ),
    );
  }

  Widget _buildCalculatedField(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
            ),
          ),
          Text(
            'IDR ${_formatPrice(value)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: color.withOpacity(0.9)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(price.toInt());
  }
}
