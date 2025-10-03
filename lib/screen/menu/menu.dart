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

  void _addMenu() {
    final name = nameController.text.trim();
    final price = int.tryParse(priceController.text.trim()) ?? 0;
    final desc = descController.text.trim();
    final img = imageController.text.trim();

    if (name.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama & harga wajib diisi", selectionColor: Colors.red),
        ),
      );
      return;
    }

    setState(() {
      menus.add(
        Menu(
          id: menus.length + 1,
          name: name,
          img: img,
          price: price,
          description: desc,
        ),
      );
    });

    nameController.clear();
    priceController.clear();
    descController.clear();
    imageController.clear();

    Navigator.pop(context);
  }

  void _showAddMenuDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Menu"),
        content: SingleChildScrollView(
          child: Column(
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(onPressed: _addMenu, child: const Text("Simpan")),
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
                        : const Icon(Icons.local_cafe, size: 40),
                    title: Text(menu.name),
                    subtitle: Text("Rp ${menu.price}"),
                    onTap: () {
                      // detail menu
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
                              Text(menu.description ?? "Tidak ada deskripsi"),
                              const SizedBox(height: 10),
                              Text("Harga: Rp ${menu.price}"),
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
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenuDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
