import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../provider/post_provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionCtrl = TextEditingController();
  bool _isSaving = false;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() {
      _imageFile = File(file.path);
    });
  }

  Future<void> _savePost() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silakan pilih gambar terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    // In a real app: upload file to server and use resulting URL.
    // For demo, we use local file path as imagePath.
    try {
      await Provider.of<PostProvider>(context, listen: false).addPost(
        userId: 'me',
        username: 'Saya',
        avatarUrl: '',
        imagePath: _imageFile!.path,
        caption: _captionCtrl.text.trim(),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan postingan: \$e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buat Postingan'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _savePost,
            child: _isSaving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Unggah', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => _showPickOptions(),
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _imageFile == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_a_photo, size: 48),
                            SizedBox(height: 8),
                            Text('Ketuk untuk memilih gambar'),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 12),
            TextField(
              controller: _captionCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tulis caption...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _savePost,
              icon: Icon(Icons.save),
              label: Text('Simpan Postingan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPickOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.close),
                title: Text('Batal'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
