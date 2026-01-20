import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/index.dart';
import 'package:flutter_application_1/provider/language_provider.dart'; // [IMPORT BARU]
import 'package:provider/provider.dart';
import 'package:flutter_application_1/provider/category_provider.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CategoryProvider>(context, listen: false);
    _loadFuture = provider.loadCategories(CategoryType.product);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);
    final lang = Provider.of<LanguageProvider>(context); // [INIT PROVIDER]

    return Scaffold(
      body: FutureBuilder(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // [TRANSLATE] Menggunakan 'loading_data' dari kamus
            return buildLoadingState(lang.getText('loading_data'));
          }

          final items = provider.categories;

          return items.isEmpty
              // [TRANSLATE] Menggunakan 'categories' dari kamus
              ? buildEmptyState(lang.getText('categories'), Icons.category_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // [TRANSLATE] Judul Header
                      return buildHeader(
                        lang.getText('product_categories'),
                        Icons.category_rounded,
                      );
                    }

                    final category = items[index - 1];

                    // Note: buildCategoryCard adalah widget external.
                    // Jika teks Edit/Hapus di dalam card belum berubah, 
                    // kita perlu mengedit file tempat buildCategoryCard berada.
                    return buildCategoryCard(
                      context,
                      category,
                      provider,
                      CategoryType.product,
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () =>
            // Dialog ini mungkin perlu diedit terpisah jika teksnya ada di dalam file komponen
            showAddEditDialog(context, provider, CategoryType.product),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}