// lib/screens/add.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/image_picker.dart';
import 'package:image_picker/image_picker.dart';
// sesuaikan path import

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _quoteCtrl = TextEditingController();
  String _category = 'band';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _saving = false;

  Future<void> _pickImage() async {
    final XFile? f = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (f == null) return;
    setState(() {
      _imageFile = File(f.path);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Pilih gambar terlebih dahulu.')));
      return;
    }

    setState(() => _saving = true);
    try {
      // final post = Memory(
      //   name: _nameCtrl.text.trim(),
      //   category: _category,
      //   quote: _quoteCtrl.text.trim(),
      //   imagePath: _imageFile!.path, // menyimpan path lokal
      // );
      // await DBHelper.instance.insertPost(post);
      // Navigator.pop(
      //   context,
      //   true,
      // ); // kembali ke gallery, berikan true agar reload
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _quoteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Postingan'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // GestureDetector(
              //   onTap: _pickImage,
              //   child: Container(
              //     height: 260,
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(12),
              //       border: Border.all(color: Colors.grey.shade300),
              //     ),
              //     child: _imageFile == null
              //         ? Center(
              //             child: Column(
              //               mainAxisSize: MainAxisSize.min,
              //               children: [
              //                 Icon(Icons.add_a_photo, size: 48),
              //                 SizedBox(height: 8),
              //                 Text('Ketuk untuk memilih gambar'),
              //               ],
              //             ),
              //           )
              //         : ClipRRect(
              //             borderRadius: BorderRadius.circular(12),
              //             child: Image.file(
              //               _imageFile!,
              //               fit: BoxFit.cover,
              //               width: double.infinity,
              //             ),
              //           ),
              //   ),
              // ),
              ImageSelector(
                isLoading: _saving,
                onChanged: (val) {
                  setState(() {
                    _imageFile = val;
                  });
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama diperlukan' : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['band', 'employee', 'customer']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _category = v);
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _quoteCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Quote',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Quote diperlukan' : null,
              ),
              SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: Icon(Icons.save),
                label: Text('Simpan Postingan'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
