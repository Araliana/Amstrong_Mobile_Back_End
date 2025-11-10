import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/index.dart';
import 'package:flutter_application_1/model/user_admin.dart';
import 'package:flutter_application_1/provider/admin_provider.dart';
import 'package:flutter_application_1/provider/role_provider.dart';
import 'package:flutter_application_1/provider/theme_provider.dart';
import 'package:flutter_application_1/utils/index.dart';
import 'package:provider/provider.dart';

class UserAdminScreen extends StatefulWidget {
  const UserAdminScreen({super.key});

  @override
  State<UserAdminScreen> createState() => _UserAdminScreenState();
}

class _UserAdminScreenState extends State<UserAdminScreen> {
  late Future<void> _loadFuture;
  @override
  void initState() {
    super.initState();
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    _loadFuture = adminProvider.loadUserAdmin();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);


    return Scaffold(
      body: FutureBuilder(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              adminProvider.isLoading) {
            return buildLoadingState("Fetching Admin Data...");
          }
          final userAdmins = adminProvider.userAdmins;
          return userAdmins.isEmpty
              ? buildEmptyState("User Admin", Icons.people_outline)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: userAdmins.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return buildHeader("User Admin", Icons.people);
                    }
                    final user = userAdmins[index - 1];
                    return _buildUserAdminCard(user);
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUserAdminCard(UserAdmin user) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.getTheme();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Aksi saat card di tap
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue.shade100,
                backgroundImage: user.img != null
                    ? NetworkImage(user.img!)
                    : null,
                child: user.img == null
                    ? Text(
                        user.username[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Info User
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama dan Role
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.fullname,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.manage_accounts,
                                size: 14,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.role!.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        idRenderer(user.id),
                      ],
                    ),
                    Text(
                      '@${user.username}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (user.lastLogin != null)
                      Row(
                        children: [
                          Icon(
                            Icons.login,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Last login: ${formatDateTime(user.lastLogin!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Created: ${formatDate(user.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.lock_reset, size: 20, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Reset Password',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditDialog(context, user);
                  } else if (value == 'reset') {
                    _showResetPasswordDialog(context, user);
                  } else if (value == 'delete') {
                    showDeleteConfirmation(
                      context,
                      title: "User Admin",
                      label: user.username,
                      isLoading: adminProvider.isLoading,
                      onDelete: () async {
                        await adminProvider.deleteUserAdmin(user.id);
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final dark = themeProvider.getTheme();
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscurePassword = true;
    int? selectedRole;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Create Admin User',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildInput(
                  controller: nameController,
                  label: 'Fullname',
                  icon: Icons.badge,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Fullname is required';
                    }
                    return null;
                  },
                  isDark: dark,
                ),
                const SizedBox(height: 16),
                buildInput(
                  controller: usernameController,
                  label: 'Username',
                  icon: Icons.alternate_email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username is required';
                    }
                    if (value.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                  isDark: dark,
                ),
                const SizedBox(height: 16),
                buildInput(
                  controller: passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  obscure: obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      !obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setDialogState(() => obscurePassword = !obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  isDark: dark,
                ),
                const SizedBox(height: 16),
                FutureBuilder(
                  future: roleProvider.loadRole(),
                  builder: (context, snapshot) {
                    return buildDropdownField(
                      label: 'Role',
                      isLoading: roleProvider.isLoading,
                      value: selectedRole.toString(),
                      items: roleProvider.roles
                          .map(
                            (role) => DropdownItem(
                              label: role.name,
                              value: role.id.toString(),
                            ),
                          )
                          .toList(),
                      prefixIcon: Icons.manage_accounts,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedRole = int.parse(value!);
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                      isDark: dark,
                    );
                  },
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          actions: buildDialogActions(
            context: context,
            confirmText: "Create",
            confirmColor: Colors.purple,
            isLoading: adminProvider.isLoading,
            onConfirm: () async {
              if (formKey.currentState!.validate()) {
                final check = await adminProvider.checkUsername(
                  username: usernameController.text,
                );
                if (check) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Username already existed!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                await adminProvider.addUserAdmin(
                  fullname: nameController.text,
                  username: usernameController.text,
                  password: passwordController.text,
                  roleId: selectedRole!,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Admin user created successfully'),
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

  void _showEditDialog(BuildContext context, UserAdmin user) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final dark = themeProvider.getTheme();
    final nameController = TextEditingController(text: user.fullname);
    final usernameController = TextEditingController(text: user.username);
    final formKey = GlobalKey<FormState>();
    int? selectedRole = user.role!.id;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Admin User'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildInput(
                  controller: nameController,
                  label: 'Fullname',
                  icon: Icons.badge,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Fullname is required';
                    }
                    return null;
                  },
                  isDark: dark,
                ),
                const SizedBox(height: 16),
                buildInput(
                  controller: usernameController,
                  label: 'Username',
                  icon: Icons.alternate_email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username is required';
                    }
                    if (value.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                  isDark: dark,
                ),
                const SizedBox(height: 16),
                FutureBuilder(
                  future: roleProvider.loadRole(),
                  builder: (context, snapshot) {
                    return buildDropdownField(
                      label: 'Role',
                      isLoading: roleProvider.isLoading,
                      value: selectedRole.toString(),
                      items: roleProvider.roles
                          .map(
                            (role) => DropdownItem(
                              label: role.name,
                              value: role.id.toString(),
                            ),
                          )
                          .toList(),
                      prefixIcon: Icons.manage_accounts,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedRole = int.parse(value!);
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: buildDialogActions(
            context: context,
            confirmText: "Edit",
            confirmColor: Colors.indigoAccent,
            isLoading: adminProvider.isLoading,
            onConfirm: () async {
              if (formKey.currentState!.validate()) {
                final check = await adminProvider.checkUsername(
                  username: usernameController.text,
                  id: user.id,
                );
                if (check) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Username already existed!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                await adminProvider.editUserAdmin(
                  id: user.id,
                  fullname: nameController.text,
                  username: usernameController.text,
                  roleId: selectedRole,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Admin user edited successfully'),
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

  void _showResetPasswordDialog(BuildContext context, UserAdmin user) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final dark = themeProvider.getTheme();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Reset Password - ${user.username}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildInput(
                  controller: newPasswordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscure: obscureNew,
                  suffix: IconButton(
                    icon: Icon(
                      !obscureNew ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => obscureNew = !obscureNew);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'New Password is required';
                    }
                    if (value.length < 6) {
                      return 'New Password must be at least 6 characters';
                    }
                    return null;
                  },
                  isDark: dark,
                ),
                const SizedBox(height: 16),
                buildInput(
                  controller: confirmPasswordController,
                  label: 'Password',
                  icon: Icons.lock,
                  obscure: obscureConfirm,
                  suffix: IconButton(
                    icon: Icon(
                      !obscureConfirm ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => obscureConfirm = !obscureConfirm);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm Password is required';
                    }
                    if (value != newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  isDark: dark,
                ),
              ],
            ),
          ),
          actions: buildDialogActions(
            context: context,
            confirmText: "Reset",
            confirmColor: Colors.amber,
            isLoading: adminProvider.isLoading,
            onConfirm: () async {
              if (formKey.currentState!.validate()) {
                await adminProvider.editUserAdmin(
                  id: user.id,
                  password: newPasswordController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset successfully'),
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
