import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/index.dart';
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
  final _profitController = TextEditingController();
  final _finalPriceController = TextEditingController();
  final _quantityController = TextEditingController();

  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isDark = false;

  // Flag untuk track manual changes
  bool _isProfitManuallyChanged = false;
  bool _isFinalPriceManuallyChanged = false;

  @override
  void initState() {
    super.initState();

    // Listen to changes for auto-calculation
    _hppController.addListener(_onHppChanged);
    _profitController.addListener(_onProfitChanged);
    _finalPriceController.addListener(_onFinalPriceChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_isInitialized) {
      _isInitialized = true;
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      productProvider.loadProducts().then((_) {
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

    _hppController.text = stock.hpp.toStringAsFixed(0);
    _profitController.text = stock.trueProfit.toStringAsFixed(0);
    _finalPriceController.text = stock.finalPrice.toStringAsFixed(0);
    _quantityController.text = stock.quantity.toString();

    _isProfitManuallyChanged = true;
    _isFinalPriceManuallyChanged = true;
  }

  void _onHppChanged() {
    if (_hppController.text.isEmpty) return;

    final hpp = double.tryParse(_hppController.text) ?? 0;

    // Auto-calculate profit dari product settings jika belum manual
    if (!_isProfitManuallyChanged && _selectedProduct != null) {
      double calculatedProfit = 0;
      if (_selectedProduct!.hasProfit) {
        if (_selectedProduct!.profitType == 'percent') {
          calculatedProfit = hpp * (_selectedProduct!.profitAmount / 100);
        } else if (_selectedProduct!.profitType == 'flat') {
          calculatedProfit = _selectedProduct!.profitAmount;
        }
      }
      _profitController.text = calculatedProfit.toStringAsFixed(0);
    }

    // Auto-calculate final price jika belum manual
    if (!_isFinalPriceManuallyChanged) {
      final profit = double.tryParse(_profitController.text) ?? 0;
      _finalPriceController.text = (hpp + profit).toStringAsFixed(0);
    }
  }

  void _onProfitChanged() {
    if (_profitController.text.isEmpty) return;

    // Mark as manually changed
    if (_hppController.text.isNotEmpty) {
      _isProfitManuallyChanged = true;
    }

    // Auto-update final price jika belum manual
    if (!_isFinalPriceManuallyChanged && _hppController.text.isNotEmpty) {
      final hpp = double.tryParse(_hppController.text) ?? 0;
      final profit = double.tryParse(_profitController.text) ?? 0;
      _finalPriceController.text = (hpp + profit).toStringAsFixed(0);
    }
  }

  void _onFinalPriceChanged() {
    if (_finalPriceController.text.isEmpty) return;

    // Mark as manually changed
    if (_hppController.text.isNotEmpty) {
      _isFinalPriceManuallyChanged = true;
    }

    // Auto-update profit based on final price
    if (_hppController.text.isNotEmpty) {
      final hpp = double.tryParse(_hppController.text) ?? 0;
      final finalPrice = double.tryParse(_finalPriceController.text) ?? 0;
      final calculatedProfit = finalPrice - hpp;
      _profitController.text = calculatedProfit.toStringAsFixed(0);
      _isProfitManuallyChanged =
          false; // Reset karena auto-calculated dari final price
    }
  }

  void _onProductChanged(String? productId) {
    if (productId == null) return;

    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    setState(() {
      _selectedProduct = productProvider.products.firstWhere(
        (p) => p.id == productId,
      );
      _isProfitManuallyChanged = false;
      _isFinalPriceManuallyChanged = false;
    });

    // Recalculate dengan product baru
    _onHppChanged();
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
      final trueProfit = double.parse(_profitController.text);
      final finalPrice = double.parse(_finalPriceController.text);
      final quantity = int.parse(_quantityController.text);

      if (widget.editStock == null) {
        await stockProvider.addStock(
          productId: _selectedProduct!.id,
          quantity: quantity,
          hpp: hpp,
          trueProfit: trueProfit,
          finalPrice: finalPrice,
        );
      } else {
        await stockProvider.editStock(
          id: widget.editStock!.id,
          productId: _selectedProduct!.id,
          quantity: quantity,
          hpp: hpp,
          trueProfit: trueProfit,
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
    _profitController.dispose();
    _finalPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    // Build dropdown items dengan foto
    final dropdownItems = productProvider.products
        .map(
          (product) => DropdownItem(
            label: product.name,
            value: product.id,
            photo: product.img,
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editStock == null ? 'Tambah Stock' : 'Edit Stock'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveStock,
          ),
        ],
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product Selection with Photo
                    buildDropdownField(
                      label: 'Product',
                      value: _selectedProduct?.id,
                      items: dropdownItems,
                      onChanged: _onProductChanged,
                      validator: (v) =>
                          v == null ? 'Product harus dipilih' : null,
                      prefixIcon: Icons.inventory_2,
                      isDark: _isDark,
                      isLoading: productProvider.isLoading,
                    ),

                    if (_selectedProduct != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        'Profit Setting: ${_selectedProduct!.hasProfit ? (_selectedProduct!.profitType == 'percent' ? '${_selectedProduct!.profitAmount}%' : 'Rp ${_formatPrice(_selectedProduct!.profitAmount)}') : 'Tidak ada'}',
                        Colors.blue,
                      ),
                      if (_selectedProduct!.hasDiscount) ...[
                        const SizedBox(height: 8),
                        _buildInfoCard(
                          'Discount Setting: ${_selectedProduct!.discountType == 'percent' ? '${_selectedProduct!.discountValue}%' : 'Rp ${_formatPrice(_selectedProduct!.discountValue!)}'}',
                          Colors.red,
                        ),
                      ],
                    ],

                    const SizedBox(height: 24),

                    // HPP Input
                    buildInput(
                      controller: _hppController,
                      label: 'HPP (Harga Pokok Penjualan)',
                      icon: Icons.attach_money,
                      isDark: _isDark,
                      mode: InputMode.number,
                      prefixText: 'Rp ',
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'HPP harus diisi';
                        final hpp = double.tryParse(v);
                        if (hpp == null || hpp <= 0) {
                          return 'HPP harus lebih dari 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Profit Input (Adjustable)
                    buildInput(
                      controller: _profitController,
                      label: 'Profit',
                      icon: Icons.trending_up,
                      isDark: _isDark,
                      mode: InputMode.number,
                      prefixText: 'Rp ',
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Profit harus diisi';
                        final profit = double.tryParse(v);
                        if (profit == null) return 'Profit harus berupa angka';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Final Price Input (Adjustable)
                    buildInput(
                      controller: _finalPriceController,
                      label: 'Final Price',
                      icon: Icons.price_check,
                      isDark: _isDark,
                      mode: InputMode.number,
                      prefixText: 'Rp ',
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Final price harus diisi';
                        }
                        final price = double.tryParse(v);
                        if (price == null || price <= 0) {
                          return 'Final price harus lebih dari 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Quantity
                    buildInput(
                      controller: _quantityController,
                      label: 'Quantity',
                      icon: Icons.inventory,
                      isDark: _isDark,
                      mode: InputMode.number,
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Quantity harus diisi';
                        final qty = int.tryParse(v);
                        if (qty == null || qty <= 0) {
                          return 'Quantity harus lebih dari 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Summary Card
                    if (_hppController.text.isNotEmpty &&
                        _profitController.text.isNotEmpty &&
                        _finalPriceController.text.isNotEmpty &&
                        _quantityController.text.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.brown[50]!, Colors.brown[100]!],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.brown[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calculate, color: Colors.brown[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'Ringkasan Kalkulasi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown[900],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildSummaryRow(
                              'HPP per unit',
                              'Rp ${_formatPrice(double.parse(_hppController.text))}',
                            ),
                            _buildSummaryRow(
                              'Profit per unit',
                              'Rp ${_formatPrice(double.parse(_profitController.text))}',
                              color: double.parse(_profitController.text) >= 0
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                            _buildSummaryRow(
                              'Final Price per unit',
                              'Rp ${_formatPrice(double.parse(_finalPriceController.text))}',
                            ),
                            const Divider(height: 24),
                            _buildSummaryRow(
                              'Quantity',
                              '${_quantityController.text} pcs',
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              'Total HPP',
                              'Rp ${_formatPrice(double.parse(_hppController.text) * int.parse(_quantityController.text))}',
                              bold: true,
                            ),
                            _buildSummaryRow(
                              'Total Profit Potential',
                              'Rp ${_formatPrice(double.parse(_profitController.text) * int.parse(_quantityController.text))}',
                              bold: true,
                              color: double.parse(_profitController.text) >= 0
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                            _buildSummaryRow(
                              'Total Value (Final × Qty)',
                              'Rp ${_formatPrice(double.parse(_finalPriceController.text) * int.parse(_quantityController.text))}',
                              bold: true,
                              color: Colors.brown[900],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
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
                    ),
                  ],
                ),
              ),
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
              style: TextStyle(
                fontSize: 13,
                color: color.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: Colors.brown[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: color ?? Colors.brown[900],
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
