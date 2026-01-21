import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/access.dart';
import 'package:flutter_application_1/provider/access_provider.dart';
import 'package:flutter_application_1/components/index.dart';
import 'package:flutter_application_1/provider/language_provider.dart'; // [IMPORT BARU]
import 'package:flutter_application_1/utils/index.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/provider/theme_provider.dart';

class AccessScreen extends StatefulWidget {
  const AccessScreen({super.key});

  @override
  State<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    final accessProvider = Provider.of<AccessProvider>(context, listen: false);
    _loadFuture = accessProvider.loadAccess();
  }

  @override
  Widget build(BuildContext context) {
    final accessProvider = Provider.of<AccessProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(context);
    final isDark = themeProvider.getTheme();

    return Scaffold(
      body: FutureBuilder(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildLoadingState(lang.getText('loading_data'));
          }
          final accesses = accessProvider.accesses;
          accesses.sort((a, b) {
            final ai = accessCategory.indexOf(a.category);
            final bi = accessCategory.indexOf(b.category);

            if (ai != bi) {
              if (ai == -1 && bi == -1) {
                return a.category.compareTo(b.category);
              } else if (ai == -1) {
                return 1;
              } else if (bi == -1) {
                return -1;
              }
              return ai.compareTo(bi);
            }

            return a.id.compareTo(b.id);
          });

          return accesses.isEmpty
              // [TRANSLATE] Empty State Title
              ? buildEmptyState(
                  lang.getText('access_title'),
                  Icons.lock_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: accesses.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return buildHeader(
                        lang.getText('access_title'),
                        Icons.lock,
                      );
                    }

                    final access = accesses[index - 1];
                    final categoryColor = getCategoryColor(access.category);

                    return Card(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: categoryColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: categoryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                access.icon,
                                size: 16,
                                color: categoryColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              access.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.link,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    access.accessPath,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.category,
                                        size: 12,
                                        color: categoryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        access.category,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: categoryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formatDate(access.createdAt),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  _showAddEditDialog(context, access),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                showDeleteConfirmation(
                                  context,
                                  title: lang.getText('access_title'),
                                  label: lang.appLocale.languageCode == "en"
                                      ? access.name
                                      : access.nameId,
                                  isLoading: accessProvider.isLoading,
                                  onDelete: () async {
                                    await accessProvider.deleteAccess(
                                      access.id,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, [Access? access]) {
    final accessProvider = Provider.of<AccessProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(context, listen: false);

    final dark = themeProvider.getTheme();
    final isEdit = access != null;
    final nameController = TextEditingController(text: access?.name ?? '');
    final nameIdController = TextEditingController(text: access?.nameId ?? '');
    final pathController = TextEditingController(
      text: access?.accessPath.substring(1) ?? '',
    );
    final sortController = TextEditingController(
      text: access?.idSort.toString(),
    );
    String? selectedCategory = access?.category;
    String? selectedIcon = access?.iconName;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          // [TRANSLATE] Dialog Title
          title: Text(
            isEdit
                ? lang.getText('permission_edit')
                : lang.getText('permission_add'),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildInput(
                    controller: nameController,
                    // [TRANSLATE] Label Name
                    label: lang.getText('name'),
                    icon: Icons.label,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '${lang.getText('name')} ${lang.getText('error_required')}';
                      }
                      if (value.length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                    isDark: dark,
                  ),
                  const SizedBox(height: 16),
                  buildInput(
                    controller: nameIdController,
                    label: lang.getText('name_id'),
                    icon: Icons.label,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '${lang.getText('name_id')} ${lang.getText('error_required')}';
                      }
                      if (value.length < 3) {
                        return 'Name Id must be at least 3 characters';
                      }
                      return null;
                    },
                    isDark: dark,
                  ),
                  const SizedBox(height: 16),
                  buildInput(
                    controller: pathController,
                    // [TRANSLATE] Label Path
                    label: lang.getText('path'),
                    icon: Icons.link,
                    prefixText: '/',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '${lang.getText('path')} ${lang.getText('error_required')}';
                      }
                      return null;
                    },
                    isDark: dark,
                  ),
                  const SizedBox(height: 16),
                  buildDropdownField(
                    // [TRANSLATE] Label Category
                    label: lang.getText('categories'),
                    value: selectedCategory,
                    simpleItems: accessCategory,
                    prefixIcon: Icons.category,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                    isDark: dark,
                  ),
                  const SizedBox(height: 16),
                  buildDropdownField(
                    // [TRANSLATE] Label Icon
                    label: lang.getText('icon'),
                    value: selectedIcon,
                    items: appIcons
                        .map(
                          (item) => DropdownItem(
                            label: item.name
                                .split("_")
                                .map(
                                  (word) =>
                                      word[0].toUpperCase() + word.substring(1),
                                )
                                .join(" "),
                            value: item.name,
                            icon: item.icon,
                          ),
                        )
                        .toList(),
                    prefixIcon: selectedIcon == null ? Icons.draw : null,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedIcon = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a icon';
                      }
                      return null;
                    },
                    isDark: dark,
                  ),
                  const SizedBox(height: 16),
                  buildInput(
                    controller: sortController,
                    // [TRANSLATE] Label Sort
                    label: lang.getText('sort_order'),
                    icon: Icons.sort_by_alpha_outlined,
                    mode: InputMode.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ID sort is required';
                      }
                      return null;
                    },
                    isDark: dark,
                  ),
                ],
              ),
            ),
          ),
          actions: buildDialogActions(
            context: context,
            // [TRANSLATE] Button Labels (Create -> Add)
            confirmText: isEdit ? lang.getText('edit') : lang.getText('add'),
            confirmColor: isEdit ? Colors.indigoAccent : Colors.purple,
            isLoading: accessProvider.isLoading,
            onConfirm: () async {
              if (formKey.currentState!.validate()) {
                if (!isEdit) {
                  await accessProvider.addAccess(
                    name: nameController.text,
                    nameId: nameIdController.text,
                    accessPath: "/${pathController.text}",
                    icon: selectedIcon!,
                    category: selectedCategory!,
                    idSort: int.parse(sortController.text),
                  );
                } else {
                  await accessProvider.editAccess(
                    name: nameController.text,
                    nameId: nameIdController.text,
                    accessPath: "/${pathController.text}",
                    category: selectedCategory!,
                    icon: selectedIcon!,
                    id: access.id,
                    idSort: int.parse(sortController.text),
                  );
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    // [TRANSLATE] Success Messages
                    content: Text(
                      isEdit
                          ? lang.getText('success_update')
                          : lang.getText('success_add'),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
