import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/image_picker.dart';
import 'package:flutter_application_1/components/index.dart';
import 'package:flutter_application_1/model/gallery.dart';
import 'package:flutter_application_1/provider/gallery_provider.dart';
import 'package:flutter_application_1/provider/theme_provider.dart';
import 'package:flutter_application_1/utils/index.dart';
import 'package:provider/provider.dart';

class GalleryAddEditScreen extends StatefulWidget {
  final String? memoId;

  const GalleryAddEditScreen({super.key, this.memoId});

  @override
  State<GalleryAddEditScreen> createState() => _GalleryAddEditScreenState();
}

class _GalleryAddEditScreenState extends State<GalleryAddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quoteController = TextEditingController();

  Memo? _initPost;
  String? _selectedCategory;
  File? _selectedImageFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final galleryProvider = Provider.of<GalleryProvider>(
      context,
      listen: false,
    );

    try {
      if (widget.memoId != null) {
        _initPost = await galleryProvider.getMemoById(widget.memoId!);
        if (_initPost != null) {
          _nameController.text = _initPost!.name;
          _quoteController.text = _initPost!.quote;
          _selectedCategory = _initPost!.category;
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final galleryProvider = Provider.of<GalleryProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final dark = themeProvider.getTheme();
    MaterialColor color = widget.memoId != null ? Colors.indigo : Colors.purple;
    final isEdit = widget.memoId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Memo" : "Add Memo"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Selector Section
            const Text(
              "Memo Image",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            ImageSelector(
              mode: PickerMode.document,
              initValue: _initPost?.img,
              onChanged: (file) {
                setState(() {
                  _selectedImageFile = file;
                });
              },
              isLoading: _isLoading,
            ),
            const SizedBox(height: 24),

            // Name Field
            buildInput(
              controller: _nameController,
              label: "Name",
              icon: Icons.person_outline,
              validator: (val) =>
                  val == null || val.isEmpty ? "Name is required" : null,
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            buildDropdownField(
              label: 'Category',
              isLoading: false,
              value: _selectedCategory,
              items: [
                DropdownItem(label: 'Customers', value: 'customers'),
                DropdownItem(label: 'Employees', value: 'employees'),
                DropdownItem(label: 'Bands', value: 'bands'),
              ],
              prefixIcon: Icons.category_outlined,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
              isDark: dark,
            ),
            const SizedBox(height: 16),

            // Quote Field
            buildInput(
              controller: _quoteController,
              label: "Quote",
              icon: Icons.format_quote,
              maxLines: 5,
              validator: (val) =>
                  val == null || val.isEmpty ? "Quote is required" : null,
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          if (!isEdit && _selectedImageFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select post image"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          String? url;
                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            if (_selectedImageFile != null) {
                              url = await uploadFile(
                                _selectedImageFile!,
                                folder: 'gallery',
                              );
                            }

                            if (!isEdit) {
                              await galleryProvider.addMemo(
                                name: _nameController.text,
                                quote: _quoteController.text,
                                category: _selectedCategory!,
                                img: url!,
                              );
                            } else {
                              await galleryProvider.editMemo(
                                id: _initPost!.id,
                                name: _nameController.text,
                                quote: _quoteController.text,
                                category: _selectedCategory!,
                                img: url ?? _initPost!.img,
                                isActive: _initPost!.isActive,
                              );
                            }

                            setState(() {
                              _isLoading = false;
                            });

                            if (mounted) {
                              Navigator.pop(context, true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEdit ? 'Post updated' : 'Post added',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() {
                              _isLoading = false;
                            });

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _isLoading
                      ? (isEdit ? "Updating" : "Adding")
                      : (isEdit ? "Update Post" : "Add Post"),
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Cancel Button
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text("Cancel", style: TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
