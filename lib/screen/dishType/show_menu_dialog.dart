import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/menu.dart';
import 'package:flutter_application_1/model/dish_type.dart';

Future<void> showMenuDialog({
  required BuildContext context,
  Menu? existingMenu,
  required List<DishType> dishTypes,
  required Function(Menu, {int? index}) onSave,
  int? index,
}) async {
  final nameController = TextEditingController(text: existingMenu?.name ?? '');
  final priceController = TextEditingController(
    text: existingMenu?.price.toString() ?? '',
  );
  final descController = TextEditingController(
    text: existingMenu?.description ?? '',
  );
  final imageController = TextEditingController(text: existingMenu?.img ?? '');

  // default pilihan kategori
  DishType selectedDishType = existingMenu?.category ?? dishTypes.first;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
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
                  DropdownButton<DishType>(
                    value: selectedDishType,
                    isExpanded: true,
                    items: dishTypes.map((dish) {
                      return DropdownMenuItem(
                        value: dish,
                        child: Text(dish.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() {
                          selectedDishType = value;
                        });
                      }
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
                    id:
                        existingMenu?.id ??
                        DateTime.now().millisecondsSinceEpoch,
                    name: name,
                    img: img,
                    price: price,
                    description: desc,
                    category: selectedDishType,
                    isActive: existingMenu?.isActive ?? true,
                    createdAt: existingMenu?.createdAt ?? DateTime.now(),
                  );

                  Navigator.pop(context); // tutup dialog dulu
                  onSave(newMenu, index: index); // baru update list
                },
                child: Text(existingMenu == null ? "Simpan" : "Update"),
              ),
            ],
          );
        },
      );
    },
  );
}
