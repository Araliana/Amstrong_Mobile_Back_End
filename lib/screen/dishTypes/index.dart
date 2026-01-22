import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/index.dart';
import 'package:flutter_application_1/provider/language_provider.dart'; // [IMPORT BARU]
import 'package:provider/provider.dart';
import 'package:flutter_application_1/provider/category_provider.dart';

class DishTypeScreen extends StatefulWidget {
  const DishTypeScreen({super.key});

  @override
  State<DishTypeScreen> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<DishTypeScreen> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CategoryProvider>(context, listen: false);
    _loadFuture = provider.loadCategories(CategoryType.menu);
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
            // [TRANSLATE] Loading state
            return buildLoadingState(lang.getText('loading_data'));
          }

          final items = provider.categories;

          return items.isEmpty
              // [TRANSLATE] Empty state title
              ? buildEmptyState(
                  lang.getText('dish_types'),
                  Icons.fastfood_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // [TRANSLATE] Header title
                      return buildHeader(
                        lang.getText('dish_types'),
                        Icons.category,
                      );
                    }

                    final category = items[index - 1];

                    // Note: buildCategoryCard adalah widget external.
                    return buildCategoryCard(
                      context,
                      category,
                      provider,
                      CategoryType.menu,
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () =>
            // Dialog ini mungkin perlu diedit terpisah jika teksnya ada di dalam file komponen
            showAddEditDialog(context, provider, CategoryType.menu),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
