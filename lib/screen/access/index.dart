import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/access.dart';
import 'package:flutter_application_1/provider/access_provider.dart';
import 'package:flutter_application_1/components/index.dart';
import 'package:flutter_application_1/utils/index.dart';
import 'package:provider/provider.dart';

class AccessScreen extends StatefulWidget {
  const AccessScreen({super.key});

  @override
  State<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> {
  final List<String> categories = [
    'ORDERS',
    'PRODUCTS & STOCK',
    'FINANCE',
    'CONTENT & MEDIA',
    'MANAGEMENT',
  ];

  @override
  Widget build(BuildContext context) {
    final acceseProvider = Provider.of<AccessProvider>(context);
    final accesses = acceseProvider.accesses;
    return Scaffold(
      body: accesses.isEmpty
          ? buildEmptyState("Access", Icons.lock_outlined)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: accesses.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return buildHeader("Access", Icons.lock);
                }
                final access = accesses[index - 1];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            access.icon,
                            size: 16,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          access.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 12),
                        idRenderer(access.id),
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
                            const Icon(
                              Icons.category,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(access.category),
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
                          onPressed: () => _showAddEditDialog(context, access),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            showDeleteConfirmation(
                              context,
                              title: "Access",
                              label: access.name,
                              isLoading: acceseProvider.isLoading,
                              onDelete: () async {
                                await acceseProvider.deleteAccess(access.id);
                              },
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
        onPressed: () => _showAddEditDialog(context),
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, [Access? access]) {
    final accessProvider = Provider.of<AccessProvider>(context, listen: false);
    final isEdit = access != null;
    final nameController = TextEditingController(text: access?.name ?? '');
    final pathController = TextEditingController(
      text: access?.accessPath.substring(1) ?? '',
    );
    String? selectedCategory = access?.category;
    String? selectedIcon = access?.iconName;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Permission' : 'Add Permission'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildInput(
                    controller: nameController,
                    label: 'Name',
                    icon: Icons.label,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      if (value.length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  buildInput(
                    controller: pathController,
                    label: 'Access Path',
                    icon: Icons.link,
                    prefixText: '/',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Access path is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  buildDropdownField(
                    label: 'Category',
                    value: selectedCategory,
                    simpleItems: categories,
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
                  ),
                  const SizedBox(height: 16),
                  buildDropdownField(
                    label: 'Icon',
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
                  ),
                ],
              ),
            ),
          ),
          actions: buildDialogActions(
            context: context,
            confirmText: isEdit ? "Edit" : "Create",
            confirmColor: isEdit ? Colors.indigoAccent : Colors.purple,
            isLoading: accessProvider.isLoading,
            onConfirm: () async {
              if (formKey.currentState!.validate()) {
                if (!isEdit) {
                  await accessProvider.addAccess(
                    name: nameController.text,
                    accessPath: pathController.text,
                    icon: selectedIcon!,
                    category: selectedCategory!,
                  );
                } else {
                  await accessProvider.editAccess(
                    name: nameController.text,
                    accessPath: pathController.text,
                    category: selectedCategory!,
                    icon: selectedIcon!,
                    id: access.id,
                  );
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEdit ? 'Permission updated' : 'Permission added',
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
