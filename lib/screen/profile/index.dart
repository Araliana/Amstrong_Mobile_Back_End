import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/model/user_admin.dart';
import 'package:flutter_application_1/provider/theme_provider.dart';
import 'package:flutter_application_1/provider/admin_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  // final UserAdmin user; // Pass current user data
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<void> _loadFuture;

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final roleController = TextEditingController();
  //final _phoneController = TextEditingController();
  //final _bioController = TextEditingController();

  File? _selectedImage;
  String? imageUrlController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    // TODO: Load from widget.user or your state management
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final currUsername = prefs.getString("curr_username") ?? "none";
    final currUser = await adminProvider.getCurrUser(currUsername);
    if (currUsername == "none") {
      print('⚠️ failed getting user info');
    }
    else {
      setState(() {
        nameController.text = currUser.fullname;
        usernameController.text = currUser.username;
        roleController.text = currUser.role?.name ?? "unknown";
        imageUrlController = currUser.img ?? "assets/logo.png";
      });
    }

  }

  //print(roleController.text);
  //_phoneController.text = "+1 234 567 890";
  //_bioController.text = "Coffee enthusiast ☕\nFlutter developer 💙";

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null || imageUrlController != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                      imageUrlController = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt("curr_id") ?? -1;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    if ( id != -1){
      try {
        await adminProvider.editUserAdmin(
          id: id,
          fullname: nameController.text,
          username: usernameController.text, 
          img: imageUrlController,
        );


        await Future.delayed(const Duration(seconds: 1)); // Simulate API call

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() => _isEditing = false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Profile" : "Profile"),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: () {
                setState(() => _isEditing = false);
                _loadUserData(); // Reset changes
              },
              child: const Text('Cancel'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image with Edit Button
              Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (imageUrlController != null
                        ? AssetImage(imageUrlController!) as ImageProvider
                        : null),
                    child: _selectedImage == null && imageUrlController == null
                        ? const Icon(Icons.person, size: 70, color: Colors.grey)
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),

              // Full Name
              TextFormField(
                controller: nameController,
                enabled: _isEditing,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: _isEditing
                      ? null
                      : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Username
              TextFormField(
                controller: usernameController,
                enabled: _isEditing,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.alternate_email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: _isEditing
                      ? null
                      : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a username';
                  }
                  if (value.contains(' ')) {
                    return 'Username cannot contain spaces';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Role

              // Phone
              //TextFormField(
              //  controller: _phoneController,
              //  enabled: _isEditing,
              //  keyboardType: TextInputType.phone,
              //  decoration: InputDecoration(
              //    labelText: 'Phone',
              //    prefixIcon: const Icon(Icons.phone_android),
              //    border: OutlineInputBorder(
              //      borderRadius: BorderRadius.circular(12),
              //    ),
              //    filled: true,
              //    fillColor: _isEditing
              //        ? null
              //        : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              //  ),
              //),
              const SizedBox(height: 16),

              // Bio
              //TextFormField(
              //  controller: _bioController,
              //  enabled: _isEditing,
              //  maxLines: 3,
              //  decoration: InputDecoration(
              //    labelText: 'Bio',
              //    prefixIcon: const Icon(Icons.info_outline),
              //    border: OutlineInputBorder(
              //      borderRadius: BorderRadius.circular(12),
              //    ),
              //    filled: true,
              //    fillColor: _isEditing
              //        ? null
              //        : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              //    alignLabelWithHint: true,
              //  ),
              //  maxLength: 150,
              //),
              const SizedBox(height: 30),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () {
                    if (_isEditing) {
                      _saveProfile();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                  icon: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Icon(_isEditing ? Icons.save : Icons.edit),
                  label: Text(_isLoading
                      ? 'Saving...'
                      : (_isEditing ? 'Save Changes' : 'Edit Profile')),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (!_isEditing) ...[
                // Role
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.badge_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Role',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              roleController.text, // <- replace with your actual role variable
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Additional Options

                const Divider(height: 40),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to change password screen
                  },
                ),

                // General Settings Section
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'General Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const Divider(height: 20),

                // Dark Mode Toggle
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return SwitchListTile(
                      secondary: Icon(
                        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: themeProvider.isDarkMode ? Colors.amber : Colors.grey[700],
                      ),
                      title: const Text('Dark Mode'),
                      subtitle: Text(
                        themeProvider.isDarkMode
                            ? 'Dark theme enabled'
                            : 'Light theme enabled',
                      ),
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    roleController.dispose();
    //_phoneController.dispose();
    //_bioController.dispose();
    super.dispose();
  }
}