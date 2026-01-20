import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/product_provider.dart';

Future<void> confirmDeleteProduct(BuildContext context, int id) async {
  // Save ScaffoldMessenger and Provider before showing dialog
  final messenger = ScaffoldMessenger.of(context);
  final provider = Provider.of<ProductProvider>(context, listen: false);

  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 28),
          SizedBox(width: 8),
          Text(
            'Delete Product',
            style: TextStyle(
              color: Colors.red[900],
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to delete this product? This action cannot be undone.',
        style: TextStyle(color: Colors.grey[700], fontSize: 15, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[700],
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Delete',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  if (ok == true) {
    try {
      await provider.deleteProduct(id);

      // Show success message using saved messenger
      messenger.showSnackBar(
        SnackBar(
          content: Text('Product deleted successfully!'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      // Show error message if delete fails
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to delete product: $e'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
