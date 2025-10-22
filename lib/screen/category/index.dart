import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/provider/category_provider.dart';
import 'package:flutter_application_1/model/category.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Kategori')),
      body: categoryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryProvider.categories.isEmpty
          ? const Center(child: Text('Belum ada kategori'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: categoryProvider.categories.length,
              itemBuilder: (context, index) {
                final Category category = categoryProvider.categories[index];
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
                          onPressed: () => _showEditDialog(
                            context,
                            categoryProvider,
                            category,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await categoryProvider.deleteCategory(
                              CategoryType.product,
                              category.id,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Kategori "${category.name}" dihapus',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, categoryProvider),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 🔹 Dialog Tambah Kategori
  void _showAddDialog(BuildContext context, CategoryProvider provider) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Kategori'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nama kategori',
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
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final exists = await provider.checkCategoryName(
                CategoryType.product,
                name,
              );
              if (exists != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama kategori sudah ada')),
                );
                return;
              }

              await provider.addCategory(CategoryType.product, name);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  /// 🔹 Dialog Edit Kategori
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
        title: const Text('Edit Kategori'),
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
                CategoryType.product,
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
                CategoryType.product,
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
