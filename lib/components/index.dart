import 'package:flutter/material.dart';

Widget buildInput({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool obscure = false,
  Widget? suffix,
  String? prefixText,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscure,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      prefixText: prefixText,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
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
}) {
  assert(
    items != null || simpleItems != null,
    'Either items or simpleItems must be provided',
  );

  if (isLoading) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: SizedBox(
            width: 4,
            height: 4,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      child: const Text("Loading..."),
    );
  }

  List<DropdownMenuItem<String>> dropdownItems;
  if (simpleItems != null) {
    dropdownItems = simpleItems
        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
        .toList();
  } else {
    dropdownItems = items!
        .map(
          (item) => DropdownMenuItem(
            value: item.value,
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: 20),
                  const SizedBox(width: 6),
                ],
                Text(item.label),
              ],
            ),
          ),
        )
        .toList();
  }

  final isValueValid = dropdownItems.any((e) => e.value == value);

  return DropdownButtonFormField<String>(
    initialValue: isValueValid ? value : null,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      errorMaxLines: 2,
    ),
    items: dropdownItems,
    onChanged: onChanged,
    validator: validator,
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
