import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/gallery_provider.dart';

Future<void> confirmDeleteGalleryPost(BuildContext context, int id) async {
  // Simpan ScaffoldMessenger dan Provider sebelum dialog
  final messenger = ScaffoldMessenger.of(context);
  final provider = Provider.of<GalleryProvider>(context, listen: false);
  final theme = Theme.of(context); // Ambil tema untuk styling

  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 28),
          SizedBox(width: 8),
          Text(
            'Hapus Postingan',
            style: TextStyle(
              color: Colors.red[900],
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: Text(
        'Anda yakin ingin menghapus postingan ini? Tindakan ini tidak dapat dibatalkan.',
        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 15, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface.withOpacity(0.7),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'Batal',
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
            'Hapus',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  if (ok == true) {
    try {
      await provider.deletePost(id);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Postingan berhasil dihapus!'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus postingan: $e'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}