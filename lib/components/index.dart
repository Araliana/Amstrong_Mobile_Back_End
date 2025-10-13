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

Widget buildDropdownField({
  required String label,
  required String? value,
  List<Map<String, String>>? items,
  List<String>? simpleItems,
  required Function(String?) onChanged,
  String? Function(String?)? validator,
  IconData? prefixIcon,
  String labelKey = 'label',
  String valueKey = 'value',
}) {
  assert(
    items != null || simpleItems != null,
    'Either items or simpleItems must be provided',
  );

  List<DropdownMenuItem<String>> dropdownItems;

  if (simpleItems != null) {
    // Simple mode: List<String>
    dropdownItems = simpleItems.map((item) {
      return DropdownMenuItem(value: item, child: Text(item));
    }).toList();
  } else {
    // Advanced mode: List<Map<String, String>>
    dropdownItems = items!.map((item) {
      return DropdownMenuItem(
        value: item[valueKey],
        child: Text(item[labelKey] ?? ''),
      );
    }).toList();
  }

  return DropdownButtonFormField<String>(
    initialValue: value,
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
  bool autoClose = true,
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
              if (autoClose) {
                Navigator.pop(context);
              }
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

Widget buildEmptyState(String title) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.people_outline, size: 100, color: Colors.grey.shade300),
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
