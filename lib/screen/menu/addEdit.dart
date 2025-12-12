import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/image_picker.dart';
import 'package:flutter_application_1/components/index.dart';
import 'package:flutter_application_1/model/menu.dart';
import 'package:flutter_application_1/provider/category_provider.dart';
import 'package:flutter_application_1/provider/menu_provider.dart';
import 'package:flutter_application_1/provider/theme_provider.dart';
import 'package:flutter_application_1/utils/index.dart';
import 'package:provider/provider.dart';

class AddEditMenuScreen extends StatefulWidget {
  final String? menuId;

  const AddEditMenuScreen({super.key, this.menuId});

  @override
  State<AddEditMenuScreen> createState() => _AddEditMenuScreenState();
}

class _AddEditMenuScreenState extends State<AddEditMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  Menu? _initMenu;

  String? _selectedCategory;
  File? _selectedImageFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);

    try {
      if (widget.menuId != null) {
        _initMenu = await menuProvider.getMenuById(widget.menuId!);
        if (_initMenu != null) {
          _nameController.text = _initMenu!.name;
          _priceController.text = _initMenu!.price.toString();
          _descController.text = _initMenu!.description;
          _selectedCategory = _initMenu!.typeId;
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final dishTypeProvider = Provider.of<CategoryProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final dark = themeProvider.getTheme();
    MaterialColor color = widget.menuId != null ? Colors.indigo : Colors.purple;
    final isEdit = widget.menuId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Menu" : "Add Menu"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Selector Section
            const Text(
              "Menu Image",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            ImageSelector(
              mode: PickerMode.document,
              initValue: _initMenu?.img,
              onChanged: (file) {
                setState(() {
                  _selectedImageFile = file;
                });
              },
              isLoading: _isLoading,
            ),
            const SizedBox(height: 24),

            // Menu Name Field
            buildInput(
              controller: _nameController,
              label: "Menu Name",
              icon: Icons.restaurant_menu,
              validator: (val) =>
                  val == null || val.isEmpty ? "Menu name is required" : null,
            ),
            const SizedBox(height: 16),

            // Price Field
            buildInput(
              controller: _priceController,
              label: "Price",
              icon: Icons.attach_money,
              mode: InputMode.number,
              validator: (val) {
                if (val == null || val.isEmpty) return "Price is required";
                if (double.tryParse(val) == null) return "Must be a number";
                if (double.parse(val) <= 0) {
                  return "Price must be greater than 0";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            FutureBuilder(
              future: _isLoading
                  ? dishTypeProvider.loadCategories(CategoryType.menu)
                  : null,
              builder: (context, snapshot) {
                return buildDropdownField(
                  label: 'Category',
                  isLoading:
                      snapshot.connectionState == ConnectionState.waiting,
                  value: _selectedCategory?.toString(),
                  items: dishTypeProvider.categories
                      .map(
                        (cat) => DropdownItem(label: cat.name, value: cat.id),
                      )
                      .toList(),
                  prefixIcon: Icons.manage_accounts,
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
                );
              },
            ),
            const SizedBox(height: 16),

            // Description Field
            buildInput(
              controller: _descController,
              label: "Description",
              icon: Icons.description,
              validator: (val) =>
                  val == null || val.isEmpty ? "Description is required" : null,
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
                                content: Text("Please select the menu's image"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          String? url;
                          setState(() {
                            _isLoading = true;
                          });
                          if (_selectedImageFile != null) {
                            url = await uploadFile(_selectedImageFile!);
                          }
                          if (!isEdit) {
                            await menuProvider.addMenu(
                              name: _nameController.text,
                              img: url!,
                              price: double.parse(_priceController.text),
                              category: _selectedCategory!,
                              description: _descController.text,
                            );
                          } else {
                            await menuProvider.editMenu(
                              name: _nameController.text,
                              img: url ?? _initMenu!.img,
                              price: double.parse(_priceController.text),
                              description: _descController.text,
                              category: _selectedCategory!,
                              isActive: _initMenu!.isActive,
                              id: _initMenu!.id,
                            );
                          }
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEdit ? 'Menu updated' : 'Menu added',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
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
                      : (isEdit ? "Update Menu" : "Add Menu"),
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
