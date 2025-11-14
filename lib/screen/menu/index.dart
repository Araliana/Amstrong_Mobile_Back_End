import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/menu.dart';
import 'package:flutter_application_1/model/dish_type.dart';
import 'package:flutter_application_1/screen/menu/add.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Menu> menus = [];

  // contoh kategori
  final List<DishType> dishTypes = [
    DishType(id: '1', name: 'Makanan'),
    DishType(id: '2', name: 'Minuman'),
    DishType(id: '3', name: 'Snack'),
  ];

  void _openAddMenu({Menu? existingMenu, int? index}) async {
    final newMenu = await Navigator.push<Menu>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddMenuPage(existingMenu: existingMenu, dishTypes: dishTypes),
      ),
    );

    if (newMenu != null) {
      setState(() {
        if (index != null) {
          menus[index] = newMenu;
        } else {
          menus.add(newMenu);
        }
      });
    }
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
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.local_dining, size: 40),
                          )
                        : const Icon(Icons.local_dining, size: 40),
                    title: Text(menu.name),
                    subtitle: Text("Rp ${menu.price} - ${menu.category.name}"),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "edit") {
                          _openAddMenu(existingMenu: menu, index: index);
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
        onPressed: () => _openAddMenu(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
