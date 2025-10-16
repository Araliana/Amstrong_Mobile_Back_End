import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/menu.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Menu> menus = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  MenuType selectedCategory = MenuType.makanan;
  int? editingIndex; // null = add, not null = edit

  void _showMenuDialog({Menu? existingMenu, int? index}) {
    // jika edit, isi field dengan data lama
    if (existingMenu != null) {
      nameController.text = existingMenu.name;
      priceController.text = existingMenu.price.toString();
      descController.text = existingMenu.description;
      imageController.text = existingMenu.img;
      selectedCategory = existingMenu.category;
      editingIndex = index;
    } else {
      nameController.clear();
      priceController.clear();
      descController.clear();
      imageController.clear();
      selectedCategory = MenuType.makanan;
      editingIndex = null;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(editingIndex == null ? "Tambah Menu" : "Edit Menu"),
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
              DropdownButton<MenuType>(
                value: selectedCategory,
                isExpanded: true,
                items: MenuType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
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
            onPressed: _saveMenu,
            child: Text(editingIndex == null ? "Simpan" : "Update"),
          ),
        ],
      ),
    );
  }

  void _saveMenu() {
    final name = nameController.text.trim();
    final price = int.tryParse(priceController.text.trim()) ?? 0;
    final desc = descController.text.trim();
    final img = imageController.text.trim();

    if (name.isEmpty || price <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nama & harga wajib diisi")));
      return;
    }

    if (editingIndex == null) {
      // CREATE
      setState(() {
        menus.add(
          Menu(
            id: menus.length + 1,
            name: name,
            img: img,
            price: price,
            description: desc,
            category: selectedCategory,
            isActive: true,
            createdAt: DateTime.now(),
          ),
        );
      });
    } else {
      // UPDATE
      setState(() {
        menus[editingIndex!] = Menu(
          id: menus[editingIndex!].id,
          name: name,
          img: img,
          price: price,
          description: desc,
          category: selectedCategory,
          isActive: menus[editingIndex!].isActive,
          createdAt: menus[editingIndex!].createdAt,
        );
      });
    }

    Navigator.pop(context);
  }

  void _deleteMenu(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Menu"),
        content: Text("Yakin ingin menghapus '${menus[index].name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                menus.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Menu")),
      body: menus.isEmpty
          ? const Center(child: Text("Belum ada menu"))
          : ListView.builder(
              itemCount: menus.length,
              itemBuilder: (context, index) {
                final menu = menus[index];
                return Card(
                  child: ListTile(
                    leading: menu.img.isNotEmpty
                        ? Image.network(
                            menu.img,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.local_dining, size: 40),
                    title: Text(menu.name),
                    subtitle: Text("Rp ${menu.price} - ${menu.category.name}"),
                    onTap: () {
                      // detail view
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(menu.name),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (menu.img.isNotEmpty)
                                Image.network(menu.img, height: 120),
                              const SizedBox(height: 10),
                              Text(menu.description),
                              const SizedBox(height: 10),
                              Text("Harga: Rp ${menu.price}"),
                              Text("Kategori: ${menu.category.name}"),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Tutup"),
                            ),
                          ],
                        ),
                      );
                    },
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "edit") {
                          _showMenuDialog(existingMenu: menu, index: index);
                        } else if (value == "delete") {
                          _deleteMenu(index);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: "edit", child: Text("Edit")),
                        const PopupMenuItem(
                          value: "delete",
                          child: Text("Hapus"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMenuDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
