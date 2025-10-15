import 'package:flutter/material.dart';

// Models
class Access {
  final int id;
  final String name;
  final String accessPath;
  final String category;
  final DateTime createdAt;

  Access({
    required this.id,
    required this.name,
    required this.accessPath,
    required this.category,
    required this.createdAt,
  });
}

class Role {
  final int id;
  final String name;
  final List<Access>? access;

  Role({required this.id, required this.name, this.access});
}

// Main Page
class RolePage extends StatefulWidget {
  const RolePage({Key? key}) : super(key: key);

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  List<Role> roles = [];
  List<Access> availableAccesses = [];

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    // Dummy data untuk testing
    availableAccesses = [
      Access(
        id: 1,
        name: 'View Dashboard',
        accessPath: '/dashboard',
        category: 'Dashboard',
        createdAt: DateTime.now(),
      ),
      Access(
        id: 2,
        name: 'View Users',
        accessPath: '/users',
        category: 'User Management',
        createdAt: DateTime.now(),
      ),
      Access(
        id: 3,
        name: 'Create User',
        accessPath: '/users/create',
        category: 'User Management',
        createdAt: DateTime.now(),
      ),
      Access(
        id: 4,
        name: 'Edit User',
        accessPath: '/users/edit',
        category: 'User Management',
        createdAt: DateTime.now(),
      ),
      Access(
        id: 5,
        name: 'View Reports',
        accessPath: '/reports',
        category: 'Reports',
        createdAt: DateTime.now(),
      ),
    ];

    roles = [
      Role(
        id: 1,
        name: 'Admin',
        access: [
          availableAccesses[0],
          availableAccesses[1],
          availableAccesses[2],
        ],
      ),
      Role(id: 2, name: 'User', access: [availableAccesses[0]]),
    ];
  }

  void _showAddRoleDialog() {
    showDialog(
      context: context,
      builder: (context) => AddRoleDialog(
        availableAccesses: availableAccesses,
        onSave: (name, selectedAccessIds) {
          setState(() {
            final selectedAccesses = availableAccesses
                .where((access) => selectedAccessIds.contains(access.id))
                .toList();

            roles.add(
              Role(id: roles.length + 1, name: name, access: selectedAccesses),
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: roles.isEmpty
          ? const Center(
              child: Text('No roles yet. Add a new role to get started.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: roles.length,
              itemBuilder: (context, index) {
                return RoleCard(role: roles[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRoleDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Add Role Dialog
class AddRoleDialog extends StatefulWidget {
  final List<Access> availableAccesses;
  final Function(String name, List<int> accessIds) onSave;

  const AddRoleDialog({
    Key? key,
    required this.availableAccesses,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddRoleDialog> createState() => _AddRoleDialogState();
}

class _AddRoleDialogState extends State<AddRoleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final Set<int> _selectedAccessIds = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(_nameController.text, _selectedAccessIds.toList());
      Navigator.pop(context);
    }
  }

  Map<String, List<Access>> _groupAccessesByCategory() {
    final Map<String, List<Access>> grouped = {};
    for (var access in widget.availableAccesses) {
      if (!grouped.containsKey(access.category)) {
        grouped[access.category] = [];
      }
      grouped[access.category]!.add(access);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedAccesses = _groupAccessesByCategory();

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Add New Role',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Role Name',
                          border: OutlineInputBorder(),
                          hintText: 'Enter role name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a role name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Access Permissions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...groupedAccesses.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            ...entry.value.map((access) {
                              return CheckboxListTile(
                                title: Text(access.name),
                                subtitle: Text(
                                  access.accessPath,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                value: _selectedAccessIds.contains(access.id),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedAccessIds.add(access.id);
                                    } else {
                                      _selectedAccessIds.remove(access.id);
                                    }
                                  });
                                },
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 8),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _handleSave,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Role Card with Accordion
class RoleCard extends StatefulWidget {
  final Role role;

  const RoleCard({Key? key, required this.role}) : super(key: key);

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.role.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('ID: ${widget.role.id}'),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Access Permissions',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  if (widget.role.access == null || widget.role.access!.isEmpty)
                    const Text(
                      'No access permissions assigned',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    ...widget.role.access!.map((access) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    access.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${access.category} - ${access.accessPath}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
