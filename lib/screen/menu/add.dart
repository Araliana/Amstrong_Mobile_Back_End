import 'package:flutter/material.dart';
import 'package:flutter_application_1/screen/menu/index.dart';
import 'package:flutter_application_1/model/menu.dart';

Future<void> showMenuDialog({
  required BuildContext context,
  Menu? existingMenu,
  required Function(Menu, {int? index}) onSave,
  int? index,
}) async {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  final imageController = TextEditingController();
  MenuType selectedCategory = MenuType.makanan;

  if (existingMenu != null) {
    nameController.text = existingMenu.name;
    priceController.text = existingMenu.price.toString();
    descController.text = existingMenu.description;
    imageController.text = existingMenu.img;
    selectedCategory = existingMenu.category;
  }

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(existingMenu == null ? "Tambah Menu" : "Edit Menu"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nama Menu"),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Harga"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
              ),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(
                  labelText: "URL/path Gambar (opsional)",
                ),
              ),
              const SizedBox(height: 10),
              StatefulBuilder(
                builder: (context, setStateDialog) {
                  return DropdownButton<MenuType>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: MenuType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedCategory = value!;
                      });
                    },
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = int.tryParse(priceController.text.trim()) ?? 0;
              final desc = descController.text.trim();
              final img = imageController.text.trim();

              if (name.isEmpty || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Nama & harga wajib diisi")),
                );
                return;
              }

              final newMenu = Menu(
                id: existingMenu?.id ?? DateTime.now().millisecondsSinceEpoch,
                name: name,
                img: img,
                price: price,
                description: desc,
                category: selectedCategory,
                isActive: existingMenu?.isActive ?? true,
                createdAt: existingMenu?.createdAt ?? DateTime.now(),
              );

              onSave(newMenu, index: index);
              Navigator.pop(context);
            },
            child: Text(existingMenu == null ? "Simpan" : "Update"),
          ),
        ],
      );
    },
  );
}
