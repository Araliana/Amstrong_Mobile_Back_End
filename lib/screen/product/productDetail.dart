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
              _buildDetailRow('Name', product.name),
              _buildDetailRow('Price', 'IDR ${_formatPrice(product.price)}'),
              if (product.discountPrice != null)
                _buildDetailRow(
                  'Discount Price',
                  'IDR ${_formatPrice(product.discountPrice!)}',
                ),
              _buildDetailRow('Stock', '${product.stock} items'),
              if (product.description != null &&
                  product.description!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
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

Widget _buildDetailRow(String label, String value) {
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
              color: Colors.brown[700],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
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
