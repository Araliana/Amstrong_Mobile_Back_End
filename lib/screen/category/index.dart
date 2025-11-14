import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/provider/category_provider.dart';
import 'package:flutter_application_1/model/category.dart';

class CategoryPage extends StatefulWidget {
  final CategoryType type;

  const CategoryPage({super.key, required this.type});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = Provider.of<CategoryProvider>(context, listen: false);

      // 🔥 Auto Seed Dish Type jika kategori adalah menu
      if (widget.type == CategoryType.menu) {
        await provider.seedDefaultDishTypes();
      }

      // Load kategori setelah seeding (jika perlu)
      provider.loadCategories(widget.type);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == CategoryType.menu
              ? 'Dish Type (Jenis Menu)'
              : 'Product Category (Kategori Produk)',
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.categories.isEmpty
          ? const Center(child: Text('Belum ada data kategori'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final Category category = provider.categories[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(category.name),
                    subtitle: Text(
                      'Dibuat: ${category.createdAt.toLocal()}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _showEditDialog(context, provider, category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await provider.deleteCategory(
                              widget.type,
                              category.id,
                            );

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Kategori "${category.name}" dihapus',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, provider),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ADD DIALOG
  void _showAddDialog(BuildContext context, CategoryProvider provider) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          widget.type == CategoryType.menu
              ? 'Tambah Dish Type'
              : 'Tambah Product Category',
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: widget.type == CategoryType.menu
                ? 'Nama jenis menu'
                : 'Nama kategori produk',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final exists = await provider.checkCategoryName(
                widget.type,
                name,
              );

              if (exists != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama kategori sudah ada')),
                );
                return;
              }

              await provider.addCategory(widget.type, name);

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // EDIT DIALOG
  void _showEditDialog(
    BuildContext context,
    CategoryProvider provider,
    Category category,
  ) {
    final TextEditingController editController = TextEditingController(
      text: category.name,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          widget.type == CategoryType.menu
              ? 'Edit Dish Type'
              : 'Edit Product Category',
        ),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            labelText: 'Nama baru',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = editController.text.trim();
              if (newName.isEmpty) return;

              final exists = await provider.checkCategoryName(
                widget.type,
                newName,
                excludeId: category.id,
              );

              if (exists != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nama kategori sudah digunakan'),
                  ),
                );
                return;
              }

              await provider.editCategory(
                widget.type,
                id: category.id,
                name: newName,
              );

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
