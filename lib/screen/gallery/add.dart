import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/image_picker.dart';
import 'package:flutter_application_1/provider/gallery_provider.dart';
import 'package:flutter_application_1/utils/index.dart';
import 'package:provider/provider.dart';

class GalleryAddEditScreen extends StatefulWidget {
  final String? memoId;
  const GalleryAddEditScreen(this.memoId, {super.key}) 

  @override
  State<GalleryAddEditScreen> createState() => _GalleryAddEditScreenState();
}

class _GalleryAddEditScreenState extends State<GalleryAddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quoteCtrl = TextEditingController();
  String _uploaderType = 'User'; 
  File? _imageFile;
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Pilih gambar terlebih dahulu.')));
      return;
    }

    setState(() => _saving = true);
    final provider = Provider.of<GalleryProvider>(context, listen: false);

    try {
      // Upload gambar ke ImageKit
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await uploadFile(_imageFile!, folder: 'gallery');
      }

      await provider.addPost(
        name: _uploaderType,
        quote: _quoteCtrl.text.trim(),
        img: imageUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Postingan berhasil ditambahkan!'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true); // Kembali & indikasikan sukses
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  void dispose() {
    _quoteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Postingan Baru'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    'Post',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Image Picker
            ImageSelector(
              isLoading: _saving,
              onChanged: (val) {
                setState(() {
                  _imageFile = val;
                });
              },
            ),
            SizedBox(height: 16),

            // Pilihan Uploader (Admin/User)
            DropdownButtonFormField<String>(
              value: _uploaderType,
              decoration: InputDecoration(
                labelText: 'Post Sebagai',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: [
                'User',
                'Admin',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _uploaderType = v);
              },
            ),
            SizedBox(height: 16),

            // Quotes / Caption
            TextFormField(
              controller: _quoteCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Tulis caption...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Caption diperlukan' : null,
            ),
          ],
        ),
      ),
    );
  }
}
