import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/image_picker.dart';
import 'package:flutter_application_1/components/index.dart';
import 'package:flutter_application_1/model/gallery.dart';
import 'package:flutter_application_1/provider/gallery_provider.dart';
import 'package:flutter_application_1/provider/language_provider.dart'; // [IMPORT BARU]
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
    // [INIT PROVIDER] (Perlu listen: false karena di dalam fungsi async/initState)
    final lang = Provider.of<LanguageProvider>(context, listen: false);

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
            // [TRANSLATE] Error Message
            content: Text('${lang.getText('error_loading')}: $e'),
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
    final lang = Provider.of<LanguageProvider>(context); // [INIT PROVIDER]
    
    final dark = themeProvider.getTheme();
    MaterialColor color = widget.memoId != null ? Colors.indigo : Colors.purple;
    final isEdit = widget.memoId != null;

    return Scaffold(
      appBar: AppBar(
        // [TRANSLATE] AppBar Title
        title: Text(isEdit ? lang.getText('edit_memo') : lang.getText('add_memo')),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Selector Section
            Text(
              // [TRANSLATE] Label
              lang.getText('memo_image'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
              // [TRANSLATE] Label Name
              label: lang.getText('name'),
              icon: Icons.person_outline,
              validator: (val) =>
                  val == null || val.isEmpty 
                      ? '${lang.getText('name')} ${lang.getText('error_required')}' 
                      : null,
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            buildDropdownField(
              // [TRANSLATE] Label Category
              label: lang.getText('categories'),
              isLoading: false,
              value: _selectedCategory,
              items: [
                // [TRANSLATE] Dropdown Items
                DropdownItem(label: lang.getText('customers'), value: 'customers'),
                DropdownItem(label: lang.getText('employees'), value: 'employees'),
                DropdownItem(label: lang.getText('bands'), value: 'bands'),
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
              // [TRANSLATE] Label Quote
              label: lang.getText('quote'),
              icon: Icons.format_quote,
              maxLines: 5,
              validator: (val) =>
                  val == null || val.isEmpty 
                      ? '${lang.getText('quote')} ${lang.getText('error_required')}' 
                      : null,
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
                              SnackBar(
                                // [TRANSLATE] Error Select Image
                                content: Text(lang.getText('select_image_error')),
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
                                  // [TRANSLATE] Success Message
                                  content: Text(
                                    isEdit 
                                        ? lang.getText('post_updated') 
                                        : lang.getText('post_added'),
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
                      // [TRANSLATE] Loading Button Text
                      ? (isEdit ? lang.getText('updating') : lang.getText('adding'))
                      // [TRANSLATE] Idle Button Text
                      : (isEdit ? lang.getText('update_post') : lang.getText('add_post')),
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
                // [TRANSLATE] Cancel Button
                label: Text(lang.getText('cancel'), style: const TextStyle(fontSize: 16)),
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