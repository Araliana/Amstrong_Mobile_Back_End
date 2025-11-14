import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/index.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/provider/category_provider.dart';

class DishTypePage extends StatefulWidget {
  const DishTypePage({super.key});

  @override
  State<DishTypePage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<DishTypePage> {
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

    return Scaffold(
      body: FutureBuilder(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildLoadingState("Fetching Dish Types...");
          }

          final items = provider.categories;

          return items.isEmpty
              ? buildEmptyState("Dish Types", Icons.fastfood_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return buildHeader("Dish Types", Icons.category);
                    }

                    final category = items[index - 1];

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
            showAddEditDialog(context, provider, CategoryType.menu),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
