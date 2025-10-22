import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/index.dart';
import 'package:flutter_application_1/model/access.dart';
import 'package:flutter_application_1/model/role.dart';
import 'package:flutter_application_1/provider/role_provider.dart';
import 'package:flutter_application_1/utils/index.dart';
import 'package:provider/provider.dart';

class AddEditRoleScreen extends StatefulWidget {
  final int? roleId;

  const AddEditRoleScreen({super.key, this.roleId});

  @override
  State<AddEditRoleScreen> createState() => _AddEditRoleScreenState();
}

class _AddEditRoleScreenState extends State<AddEditRoleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late Set<int> _selectedAccessIds = {};
  late Role initRole;
  Map<String, List<Access>> _groupedAccesses = {};
  bool _isLoadingAccess = true;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAccessData(); // Ubah ini
    });
    if (widget.roleId != null) {
      _loadRoleData();
    }
  }

  Future<void> _loadAccessData() async {
    final grouped = await groupAccessesByCategory(context);

    setState(() {
      _groupedAccesses = grouped;
      _isLoadingAccess = false;
    });
  }

  Future<void> _loadRoleData() async {
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);
    final role = await roleProvider.getRole(widget.roleId!);

    setState(() {
      _nameController.text = role.name;
      _selectedAccessIds = role.access?.map((item) => item.id).toSet() ?? {};
      initRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);
    final isEdit = widget.roleId != null;
    MaterialColor color = widget.roleId != null ? Colors.indigo : Colors.purple;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header - FIXED
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: color.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isEdit ? "Edit Role (${initRole.name})" : 'Add New Role',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                  ),
                ),
              ],
            ),
          ),

          // Content - SCROLLABLE (Role Name + Access List)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role Name Card
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.badge_outlined,
                                  size: 20,
                                  color: Colors.grey.shade700,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Role Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Role Name',
                                hintText: 'e.g., Administrator, Manager, Staff',
                                prefixIcon: const Icon(Icons.workspace_premium),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a role name';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Access Permissions Header
                    Row(
                      children: [
                        Icon(
                          Icons.security,
                          size: 20,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Access Permissions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_selectedAccessIds.length} selected',
                            style: TextStyle(
                              color: color.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Access Categories
                    _isLoadingAccess
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading access permissions...',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _groupedAccesses.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.folder_off_outlined,
                                      size: 56,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'No Access Data Available',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'There are no access permissions to display.\nPlease contact your administrator to set up access.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  OutlinedButton.icon(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(
                                      Icons.arrow_back,
                                      size: 18,
                                    ),
                                    label: const Text('Go Back'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            children: _groupedAccesses.entries.map((entry) {
                              final categoryColor = getCategoryColor(entry.key);
                              final selectedInCategory = entry.value
                                  .where(
                                    (a) => _selectedAccessIds.contains(a.id),
                                  )
                                  .length;
                              entry.value.sort(
                                (a, b) => (a.idSort).compareTo(b.idSort),
                              );

                              return Card(
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 12),
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: Theme(
                                  data: Theme.of(
                                    context,
                                  ).copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    initiallyExpanded: true,
                                    tilePadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    childrenPadding: const EdgeInsets.only(
                                      left: 8,
                                      right: 8,
                                      bottom: 12,
                                    ),
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: categoryColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.folder_outlined,
                                        color: categoryColor,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: categoryColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '$selectedInCategory of ${entry.value.length} selected',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    children: entry.value.map((access) {
                                      final isSelected = _selectedAccessIds
                                          .contains(access.id);

                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 6,
                                          left: 8,
                                          right: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? categoryColor.withValues(
                                                  alpha: 0.05,
                                                )
                                              : Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? categoryColor.withValues(
                                                    alpha: 0.3,
                                                  )
                                                : Colors.grey.shade200,
                                          ),
                                        ),
                                        child: CheckboxListTile(
                                          value: isSelected,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              if (value == true) {
                                                _selectedAccessIds.add(
                                                  access.id,
                                                );
                                              } else {
                                                _selectedAccessIds.remove(
                                                  access.id,
                                                );
                                              }
                                            });
                                          },
                                          title: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? categoryColor
                                                            .withValues(
                                                              alpha: 0.15,
                                                            )
                                                      : Colors.grey.shade200,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Icon(
                                                  access.icon,
                                                  size: 16,
                                                  color: isSelected
                                                      ? categoryColor
                                                      : Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  access.name,
                                                  style: TextStyle(
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          subtitle: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 32,
                                            ),
                                            child: Text(
                                              access.accessPath,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          activeColor: categoryColor,
                                          dense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
          ),

          // Footer Actions - FIXED
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: buildDialogActions(
                context: context,
                confirmText: isEdit ? 'Update' : "Create",
                confirmColor: color,
                isLoading: false,
                onConfirm: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_selectedAccessIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please select the permision before submit!',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (isEdit) {
                      await roleProvider.editRole(
                        name: _nameController.text,
                        accesses: _selectedAccessIds,
                        id: initRole.id,
                      );
                    } else {
                      await roleProvider.addRole(
                        name: _nameController.text,
                        accesses: _selectedAccessIds,
                      );
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Role ${isEdit ? "updated" : "created"} successfully',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
