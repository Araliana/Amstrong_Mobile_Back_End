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
  final String? photo; // URL atau path foto

  DropdownItem({
    required this.label,
    required this.value,
    this.icon,
    this.photo,
  });
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
  // Dark mode colors
  final textColor = isDark ? Colors.white : Colors.black;
  final labelColor = isDark ? Colors.white70 : Colors.black87;
  final fillColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
  final dialogBgColor = isDark ? Colors.grey.shade900 : Colors.white;
  final borderColor = isDark ? Colors.blueAccent : Colors.blue;
  final iconColor = isDark ? Colors.white70 : Colors.black54;
  final loadingTextColor = isDark ? Colors.white54 : Colors.black54;
  final dividerColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

  assert(
    items != null || simpleItems != null,
    'Either items or simpleItems must be provided',
  );

  // Convert simpleItems to DropdownItem if needed
  final List<DropdownItem> dropdownItems = simpleItems != null
      ? simpleItems
            .map((item) => DropdownItem(label: item, value: item))
            .toList()
      : items!;

  // Find selected item
  final selectedItem = dropdownItems.firstWhere(
    (item) => item.value == value,
    orElse: () => DropdownItem(label: '', value: ''),
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

  return FormField<String>(
    initialValue: value,
    validator: validator,
    builder: (FormFieldState<String> field) {
      return InputDecorator(
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          errorText: field.errorText,
          errorMaxLines: 2,
        ),
        child: InkWell(
          onTap: () async {
            final selected = await Navigator.of(field.context).push<String>(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => _FullScreenDropdownDialog(
                  label: label,
                  items: dropdownItems,
                  selectedValue: value,
                  isDark: isDark,
                  textColor: textColor,
                  labelColor: labelColor,
                  fillColor: fillColor,
                  dialogBgColor: dialogBgColor,
                  borderColor: borderColor,
                  iconColor: iconColor,
                  dividerColor: dividerColor,
                ),
              ),
            );

            if (selected != null) {
              field.didChange(selected);
              onChanged(selected);
            }
          },
          child: Row(
            children: [
              if (selectedItem.icon != null) ...[
                Icon(selectedItem.icon, size: 20, color: iconColor),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  value != null && selectedItem.label.isNotEmpty
                      ? selectedItem.label
                      : 'Select $label',
                  style: TextStyle(
                    color: value != null && selectedItem.label.isNotEmpty
                        ? textColor
                        : loadingTextColor,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: iconColor),
            ],
          ),
        ),
      );
    },
  );
}

class _FullScreenDropdownDialog extends StatefulWidget {
  final String label;
  final List<DropdownItem> items;
  final String? selectedValue;
  final bool isDark;
  final Color textColor;
  final Color labelColor;
  final Color fillColor;
  final Color dialogBgColor;
  final Color borderColor;
  final Color iconColor;
  final Color dividerColor;

  const _FullScreenDropdownDialog({
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.isDark,
    required this.textColor,
    required this.labelColor,
    required this.fillColor,
    required this.dialogBgColor,
    required this.borderColor,
    required this.iconColor,
    required this.dividerColor,
  });

  @override
  State<_FullScreenDropdownDialog> createState() =>
      __FullScreenDropdownDialogState();
}

class __FullScreenDropdownDialogState extends State<_FullScreenDropdownDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<DropdownItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.label.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.dialogBgColor,
      appBar: AppBar(
        backgroundColor: widget.dialogBgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: widget.iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.label,
          style: TextStyle(
            color: widget.textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(color: widget.textColor),
              decoration: InputDecoration(
                hintText: 'Search ${widget.label}...',
                hintStyle: TextStyle(color: widget.iconColor),
                prefixIcon: Icon(Icons.search, color: widget.iconColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: widget.iconColor),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: widget.fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.borderColor, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _filteredItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: widget.iconColor),
                  const SizedBox(height: 16),
                  Text(
                    'No results found',
                    style: TextStyle(fontSize: 16, color: widget.iconColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try a different search term',
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.iconColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _filteredItems.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: widget.dividerColor,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                final isSelected = item.value == widget.selectedValue;

                return InkWell(
                  onTap: () => Navigator.pop(context, item.value),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Photo (if exists)
                        if (item.photo != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.photo!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 180,
                                  color: widget.fillColor,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: widget.iconColor,
                                    size: 48,
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 180,
                                      color: widget.fillColor,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                widget.borderColor,
                                              ),
                                        ),
                                      ),
                                    );
                                  },
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Label and Icon
                        Row(
                          children: [
                            if (item.icon != null) ...[
                              Icon(
                                item.icon,
                                size: 24,
                                color: isSelected
                                    ? widget.borderColor
                                    : widget.iconColor,
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected
                                      ? widget.borderColor
                                      : widget.textColor,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: widget.borderColor,
                                size: 24,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
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
