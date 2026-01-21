import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/stock.dart';
import 'package:intl/intl.dart';

void showStockDetail(BuildContext context, Stock stock) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.brown[700]!, Colors.brown[900]!],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.inventory_2,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Detail Stock',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stock.productName ?? 'Unknown Product',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Informasi Dasar'),
                    const SizedBox(height: 12),
                    _buildDetailRow('Stock ID', '#${stock.id}'),
                    _buildDetailRow('Product ID', '#${stock.productId}'),
                    _buildDetailRow('Quantity', '${stock.quantity} pcs'),
                    _buildDetailRow(
                      'Tanggal Dibuat',
                      _formatDate(stock.createdAt),
                    ),
                    if (stock.updatedAt != null)
                      _buildDetailRow(
                        'Terakhir Update',
                        _formatDate(stock.updatedAt),
                      ),

                    const SizedBox(height: 24),
                    _buildSectionTitle('Breakdown Harga'),
                    const SizedBox(height: 12),

                    // HPP
                    _buildPriceRow(
                      'HPP (Harga Pokok Penjualan)',
                      stock.hpp,
                      Colors.orange,
                      Icons.attach_money,
                    ),
                    const SizedBox(height: 8),

                    // Profit
                    _buildPriceRow(
                      'Profit',
                      stock.trueProfit,
                      Colors.green,
                      Icons.trending_up,
                    ),
                    const SizedBox(height: 8),

                    // Divider
                    const Divider(thickness: 1),
                    const SizedBox(height: 8),

                    // Selling Price
                    _buildPriceRow(
                      'Harga Jual (Kalkulasi)',
                      stock.sellingPrice,
                      Colors.blue,
                      Icons.sell,
                    ),

                    // Discount if exists
                    if (stock.discount > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.local_offer, color: Colors.red[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Diskon',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'IDR ${_formatPrice(stock.discount)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                  Text(
                                    '${stock.discountPercentage.toStringAsFixed(1)}% dari harga jual',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.red[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),
                    const Divider(thickness: 2),
                    const SizedBox(height: 8),

                    // Final Price
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.brown[700]!, Colors.brown[900]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.price_check, color: Colors.white),
                              SizedBox(width: 12),
                              Text(
                                'Harga Akhir',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'IDR ${_formatPrice(stock.finalPrice)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    _buildSectionTitle('Kalkulasi'),
                    const SizedBox(height: 8),
                    Text(
                      'HPP + Profit = Harga Jual\n'
                      'IDR ${_formatPrice(stock.hpp)} + IDR ${_formatPrice(stock.trueProfit)} = IDR ${_formatPrice(stock.sellingPrice)}\n\n'
                      '${stock.discount > 0 ? 'Harga Jual - Diskon = Harga Akhir\nIDR ${_formatPrice(stock.sellingPrice)} - IDR ${_formatPrice(stock.discount)} = IDR ${_formatPrice(stock.finalPrice)}' : 'Harga Akhir = Harga Jual (Tanpa Diskon)'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ),
        const Text(': ', style: TextStyle(fontSize: 13)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildPriceRow(String label, double value, Color color, IconData icon) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          'IDR ${_formatPrice(value)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
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

String _formatDate(DateTime? date) {
  if (date == null) return '-';
  final formatter = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');
  return formatter.format(date);
}
