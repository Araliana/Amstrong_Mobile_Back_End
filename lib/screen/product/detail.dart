import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/product.dart';
import 'package:flutter_application_1/utils/index.dart';

void showProductDetail(BuildContext context, Product product) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.brown[700]),
            const SizedBox(width: 8),
            Text(
              'Product Detail',
              style: TextStyle(
                color: Colors.brown[900],
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- GAMBAR PRODUK ---
              if (product.img != null && product.img!.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.brown[50],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.img!,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, error, stackTrace) => Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          size: 60,
                          color: Colors.brown[300],
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // --- NAMA PRODUK ---
              _buildDetailRow('Name', product.name),

              // --- STOCK INFO ---
              _buildDetailRow(
                'Total Stock',
                '${product.totalAvailableQuantity}',
                highlight: product.isAvailable,
              ),

              // --- HPP (dari oldest stock) ---
              if (product.currentHPP != null)
                _buildDetailRow(
                  'HPP (Base)',
                  formatCurrency(product.currentHPP!),
                ),

              // --- PROFIT INFO ---
              if (product.hasProfit) ...[
                _buildDetailRow(
                  'Profit',
                  product.profitType == 'percent'
                      ? '${product.profitAmount}%'
                      : formatCurrency(product.profitAmount!),
                  textColor: Colors.green[700],
                ),
              ],

              // --- CURRENT PRICE (tanpa discount) ---
              if (product.currentPrice != null)
                _buildDetailRow(
                  'Current Price',
                  formatCurrency(product.currentPrice!),
                  highlight: true,
                ),

              // --- DISCOUNT INFO ---
              if (product.hasDiscount) ...[
                _buildDetailRow(
                  'Discount',
                  product.discountType == 'percent'
                      ? '${product.discountValue}%'
                      : formatCurrency(product.discountValue!),
                  textColor: Colors.red[700],
                ),
                if (product.discountedPrice != null)
                  _buildDetailRow(
                    'Discounted Price',
                    formatCurrency(product.discountedPrice!),
                    highlight: true,
                    textColor: Colors.red[700],
                  ),
              ],

              // --- FINAL PRICE ---
              if (product.finalPrice != null) ...[
                const Divider(height: 24),
                _buildDetailRow(
                  'Final Price',
                  formatCurrency(product.finalPrice!),
                  highlight: true,
                  textColor: Colors.brown[900],
                ),
              ],

              // --- DESCRIPTION ---
              if (product.description != null &&
                  product.description!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.brown[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description!,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),

              // --- STOCK DETAILS ---
              if (product.hasStock && product.stocks!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Stock Details',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.brown[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...product.stocks!
                    .where((s) => s.quantity > 0)
                    .map(
                      (stock) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.brown[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: stock.id == product.oldestAvailableStock?.id
                                ? Colors.green[300]!
                                : Colors.brown[200]!,
                            width: stock.id == product.oldestAvailableStock?.id
                                ? 2
                                : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (stock.id == product.oldestAvailableStock?.id)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Active (Oldest)',
                                  style: TextStyle(
                                    color: Colors.green[800],
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Qty: ${stock.quantity}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.brown[800],
                                  ),
                                ),
                                Text(
                                  'HPP: ${formatCurrency(stock.hpp)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.brown[700],
                                  ),
                                ),
                              ],
                            ),
                            if (stock.createdAt != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Added: ${formatDate(stock.createdAt!)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.brown[700],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Close',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildDetailRow(
  String label,
  String value, {
  bool highlight = false,
  Color? textColor,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: highlight ? Colors.green[700] : Colors.brown[700],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color:
                  textColor ??
                  (highlight ? Colors.green[700] : Colors.grey[700]),
              fontSize: 14,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
      ],
    ),
  );
}
