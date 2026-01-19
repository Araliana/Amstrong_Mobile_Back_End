import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/product.dart';
import 'package:intl/intl.dart';

void showProductDetail(BuildContext context, Product product) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.brown[700]),
            SizedBox(width: 8),
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
              SizedBox(height: 16),

              // --- NAMA PRODUK ---
              _buildDetailRow('Name', product.name),

              // --- LOGIKA HARGA & DISKON ---
              // Jika ada discountPrice (nominal potongan), kita hitung harga akhir
              if (product.discountPrice != null &&
                  product.discountPrice! > 0) ...[
                // 1. Harga Asli
                _buildDetailRow(
                  'Original Price',
                  'IDR ${_formatPrice(product.price)}',
                ),

                // 2. Nominal Potongan (Diskon)
                _buildDetailRow(
                  'Discount',
                  '- IDR ${_formatPrice(product.discountPrice!)}',
                  textColor: Colors.red,
                ),

                // 3. Harga Akhir (Harga Asli - Potongan)
                _buildDetailRow(
                  'Final Price',
                  'IDR ${_formatPrice(product.price - product.discountPrice!)}',
                  highlight: true,
                ),
              ] else ...[
                // Jika tidak ada diskon, tampilkan harga normal saja
                _buildDetailRow('Price', 'IDR ${_formatPrice(product.price)}'),
              ],

              // --- STOK ---
              _buildDetailRow('Stock', '${product.stock} items'),

              // --- DESKRIPSI ---
              if (product.description != null &&
                  product.description!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.brown[700],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.brown[700],
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

String _formatPrice(double price) {
  final formatter = NumberFormat('#,###', 'id_ID');
  return formatter.format(price.toInt());
}
