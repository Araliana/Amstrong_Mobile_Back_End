import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/menu.dart';
import 'package:flutter_application_1/model/dish_type.dart';

class AddMenuPage extends StatefulWidget {
  final Menu? existingMenu;
  final List<DishType> dishTypes;

  const AddMenuPage({super.key, this.existingMenu, required this.dishTypes});

  @override
  State<AddMenuPage> createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  final imageController = TextEditingController();

  late DishType selectedType;

  @override
  void initState() {
    super.initState();
    if (widget.existingMenu != null) {
      final m = widget.existingMenu!;
      nameController.text = m.name;
      priceController.text = m.price.toString();
      descController.text = m.description;
      imageController.text = m.img;
      selectedType = m.category;
    } else {
      selectedType = widget.dishTypes.first;
    }
  }

  void _saveMenu() {
    if (!_formKey.currentState!.validate()) return;

    final newMenu = Menu(
      id: widget.existingMenu?.id ?? DateTime.now().millisecondsSinceEpoch,
      name: nameController.text.trim(),
      img: imageController.text.trim(),
      price: int.parse(priceController.text.trim()),
      description: descController.text.trim(),
      category: selectedType,
      isActive: widget.existingMenu?.isActive ?? true,
      createdAt: widget.existingMenu?.createdAt ?? DateTime.now(),
    );

    Navigator.pop(context, newMenu);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingMenu != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Edit Menu" : "Tambah Menu")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nama Menu"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Wajib diisi" : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Harga"),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Wajib diisi";
                  if (int.tryParse(val) == null) return "Harus angka";
                  return null;
                },
              ),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
                maxLines: 3,
              ),
              TextFormField(
                controller: imageController,
                decoration: const InputDecoration(
                  labelText: "URL/path Gambar (opsional)",
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<DishType>(
                value: selectedType,
                items: widget.dishTypes.map((dish) {
                  return DropdownMenuItem(value: dish, child: Text(dish.name));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
                decoration: const InputDecoration(labelText: "Kategori"),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveMenu,
                icon: const Icon(Icons.save),
                label: Text(isEditing ? "Simpan Perubahan" : "Tambah Menu"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
