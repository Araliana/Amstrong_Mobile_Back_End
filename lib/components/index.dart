import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/model/category.dart';
import 'package:flutter_application_1/provider/auth_provider.dart';
import 'package:flutter_application_1/provider/category_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

enum InputMode { text, number, mixed }

Widget buildInput({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool obscure = false,
  Widget? suffix,
  String? prefixText,
  String? Function(String?)? validator,
  InputMode mode = InputMode.mixed,
  bool isDark = false,
}) {
  final textColor = isDark ? Colors.white : Colors.black;
  final labelColor = isDark ? Colors.white70 : Colors.black87;
  final fillColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
  final borderColor = isDark ? Colors.blueAccent : Colors.blue;
  final iconColor = isDark ? Colors.white70 : Colors.black54;

  TextInputType keyboardType = TextInputType.text;
  List<TextInputFormatter> formatters = [];

  switch (mode) {
    case InputMode.number:
      keyboardType = TextInputType.number;
      formatters = [FilteringTextInputFormatter.digitsOnly];
      break;

    case InputMode.text:
      keyboardType = TextInputType.text;
      formatters = [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))];
      break;

    case InputMode.mixed:
      keyboardType = TextInputType.text;
      break;
  }

  return TextFormField(
    controller: controller,
    obscureText: obscure,
    validator: validator,
    keyboardType: keyboardType,
    inputFormatters: formatters,
    style: TextStyle(color: textColor),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: labelColor),
      prefixIcon: Icon(icon, color: iconColor),
      suffixIcon: suffix,
      prefixText: prefixText,
      prefixStyle: TextStyle(color: labelColor),
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

class DropdownItem {
  final String label;
  final String value;
  final IconData? icon;

  DropdownItem({required this.label, required this.value, this.icon});
}

Widget buildDropdownField({
  required String label,
  required String? value,
  List<DropdownItem>? items,
  List<String>? simpleItems,
  required Function(String?) onChanged,
  String? Function(String?)? validator,
  IconData? prefixIcon,
  bool isLoading = false,
  bool isDark = false,
}) {
  //final isDark = ThemeProvider().isDarkMode;

  // Dark mode colors
  final textColor = isDark ? Colors.white : Colors.black;
  final labelColor = isDark ? Colors.white70 : Colors.black87;
  final fillColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
  final dropdownBgColor = isDark ? Colors.grey.shade900 : Colors.white;
  final borderColor = isDark ? Colors.blueAccent : Colors.blue;
  final iconColor = isDark ? Colors.white70 : Colors.black54;
  final loadingTextColor = isDark ? Colors.white54 : Colors.black54;

  assert(
    items != null || simpleItems != null,
    'Either items or simpleItems must be provided',
  );

  if (isLoading) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: SizedBox(
            width: 4,
            height: 4,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Colors.blueAccent : Colors.blue,
              ),
            ),
          ),
        ),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      child: Text("Loading...", style: TextStyle(color: loadingTextColor)),
    );
  }

  List<DropdownMenuItem<String>> dropdownItems;
  if (simpleItems != null) {
    dropdownItems = simpleItems
        .map(
          (item) => DropdownMenuItem(
            value: item,
            child: Text(item, style: TextStyle(color: textColor)),
          ),
        )
        .toList();
  } else {
    dropdownItems = items!
        .map(
          (item) => DropdownMenuItem(
            value: item.value,
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: 20, color: iconColor),
                  const SizedBox(width: 6),
                ],
                Text(item.label, style: TextStyle(color: textColor)),
              ],
            ),
          ),
        )
        .toList();
  }

  final isValueValid = dropdownItems.any((e) => e.value == value);

  return DropdownButtonFormField<String>(
    initialValue: isValueValid ? value : null,
    dropdownColor: dropdownBgColor,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: labelColor),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: iconColor)
          : null,
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      errorMaxLines: 2,
    ),
    items: dropdownItems,
    onChanged: onChanged,
    validator: validator,
    style: TextStyle(color: textColor),
    icon: Icon(Icons.arrow_drop_down, color: iconColor),
  );
}

List<Widget> buildDialogActions({
  required BuildContext context,
  required Function onConfirm,
  String cancelText = "Cancel",
  String confirmText = "OK",
  Color confirmColor = Colors.brown,
  bool isLoading = false,
}) {
  return [
    TextButton(
      onPressed: isLoading
          ? null
          : () {
              Navigator.pop(context);
            },
      child: Text(cancelText),
    ),
    ElevatedButton(
      onPressed: isLoading
          ? null
          : () async {
              await onConfirm();
            },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        backgroundColor: confirmColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(confirmText, style: const TextStyle(color: Colors.white)),
    ),
  ];
}

Widget buildEmptyState(String title, IconData icon) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 100, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(
          'No $title',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap the + button to add your first ${title.toLowerCase()}',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget buildLoadingState([String? message]) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2C39B8).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C39B8)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          message ?? 'Loading...',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    ),
  );
}

Widget buildHeader(String title, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(child: Divider(thickness: 1, endIndent: 10)),
        Icon(icon, size: 28),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.0,
          ),
        ),
        const Expanded(child: Divider(thickness: 1, indent: 10)),
      ],
    ),
  );
}

Widget idRenderer(int id) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.green.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.green.shade200),
    ),
    child: Text(
      'ID: $id',
      style: TextStyle(
        fontSize: 12,
        color: Colors.green.shade700,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

void showDeleteConfirmation(
  BuildContext context, {
  required bool isLoading,
  required Function onDelete,
  required String title,
  required String label,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete $title'),
      content: Text('Are you sure you want to delete "$label"?'),
      actions: buildDialogActions(
        context: context,
        confirmText: "Delete",
        confirmColor: Colors.red,
        isLoading: isLoading,
        onConfirm: () async {
          await onDelete();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    ),
  );
}

void showLogoutDialog(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: authProvider.isLoading
                ? null
                : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: authProvider.isLoading
                ? null
                : () async {
                    await authProvider.logout();
                    context.go('/login');
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

Widget buildCategoryCard(
  BuildContext context,
  Category category,
  CategoryProvider provider,
  CategoryType categoryMode,
) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 4),
    child: ListTile(
      title: Text(category.name),
      subtitle: Text(
        'Created at: ${category.createdAt}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () =>
                showAddEditDialog(context, provider, categoryMode, category),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDeleteConfirmation(
                context,
                title: "Category",
                label: category.name,
                isLoading: provider.isLoading,
                onDelete: () async {
                  await provider.deleteCategory(categoryMode, category.id);
                },
              );
            },
          ),
        ],
      ),
    ),
  );
}

void showAddEditDialog(
  BuildContext context,
  CategoryProvider provider,
  CategoryType categoryMode, [
  Category? category,
]) {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController(
    text: category?.name,
  );
  final isEdit = category != null;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(
          isEdit
              ? 'Edit ${categoryMode == CategoryType.menu ? "Dish Type" : "Product Category"}'
              : 'Add ${categoryMode == CategoryType.menu ? "Dish Type" : "Product Category"}',
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildInput(
                  controller: nameController,
                  label: "Category Name",
                  icon: categoryMode == CategoryType.menu
                      ? Icons.restaurant_menu
                      : Icons.inventory_2,
                  validator: (val) => val == null || val.isEmpty
                      ? "Category name is required"
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: buildDialogActions(
          context: context,
          confirmText: isEdit ? "Edit" : "Create",
          confirmColor: isEdit ? Colors.indigoAccent : Colors.purple,
          isLoading: provider.isLoading,
          onConfirm: () async {
            if (formKey.currentState!.validate()) {
              if (!isEdit) {
                await provider.addCategory(
                  categoryMode,
                  nameController.text.trim(),
                );
              } else {
                await provider.editCategory(
                  categoryMode,
                  id: category.id,
                  name: nameController.text.trim(),
                );
              }

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEdit ? 'Category updated' : 'Category added'),
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
