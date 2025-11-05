import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum PickerMode { avatar, document }

class ImageSelector extends StatefulWidget {
  ImageSelector({
    super.key,
    this.initValue,
    this.onChanged,
    this.isLoading,
    this.mode = PickerMode.document,
  });

  final String? initValue;
  final Function(File?)? onChanged;
  final bool? isLoading;
  final PickerMode mode;

  @override
  State<ImageSelector> createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          if (widget.onChanged != null) {
            widget.onChanged!(_selectedImage!);
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final Color iconColor = isDestructive
        ? Colors.red
        : const Color(0xFF2C39B8);
    final Color textColor = isDestructive ? Colors.red : Colors.black87;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmall ? 8 : 10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: isSmall ? 24 : 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isSmall ? 16 : 18,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isSmall ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: isSmall ? 20 : 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showImageSourceBottomSheet(BuildContext context) async {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
            top: 24,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select Image Source",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isSmall ? 20 : 26,
                  ),
                ),
                SizedBox(height: isSmall ? 16 : 20),
                _buildImageSourceOption(
                  context: context,
                  icon: Icons.camera_alt,
                  title: "Camera",
                  subtitle: "Take a new photo",
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera, context);
                  },
                ),
                SizedBox(height: isSmall ? 8 : 16),
                _buildImageSourceOption(
                  context: context,
                  icon: Icons.photo_library,
                  title: "Gallery",
                  subtitle: "Choose from gallery",
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery, context);
                  },
                ),
                if (_selectedImage != null) ...[
                  SizedBox(height: 8),
                  const Divider(height: 16),
                  _buildImageSourceOption(
                    context: context,
                    icon: Icons.delete_outline,
                    title: "Remove Photo",
                    subtitle: "Delete current image",
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _selectedImage = null;
                        if (widget.onChanged != null) {
                          widget.onChanged!(null);
                        }
                      });
                    },
                    isDestructive: true,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarMode(bool isSmall) {
    return Stack(
      children: [
        CircleAvatar(
          radius: isSmall ? 70 : 100,
          backgroundColor: Colors.grey[300],
          backgroundImage: _selectedImage != null
              ? FileImage(_selectedImage!)
              : widget.initValue != null
              ? NetworkImage(widget.initValue!)
              : null,
          child: _selectedImage == null && widget.initValue == null
              ? Icon(
                  Icons.person,
                  size: isSmall ? 80 : 100,
                  color: Colors.grey[400],
                )
              : null,
        ),
        !(widget.isLoading ?? false)
            ? Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  height: isSmall ? 30 : 45,
                  width: isSmall ? 30 : 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1E5B),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                    onPressed: () => _showImageSourceBottomSheet(context),
                    icon: Icon(
                      _selectedImage == null ? Icons.photo_camera : Icons.edit,
                    ),
                    color: Colors.white,
                  ),
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }

  Widget _buildDocumentMode(bool isSmall) {
    return Container(
      width: double.infinity,
      height: 270,
      decoration: BoxDecoration(
        color: _selectedImage != null ? Colors.grey[200] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedImage != null
              ? Colors.grey.withValues(alpha: 0.3)
              : const Color(0xFF2C39B8).withValues(alpha: 0.3),
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
          style: _selectedImage != null ? BorderStyle.solid : BorderStyle.solid,
        ),
      ),
      child: Stack(
        children: [
          if (_selectedImage != null || widget.initValue != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      widget.initValue!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C39B8).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      size: isSmall ? 48 : 64,
                      color: const Color(0xFF2C39B8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Tap the button to select source",
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: isSmall ? 16 : 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Divider(indent: 50, endIndent: 50, height: 5, thickness: 2),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C39B8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Select Image",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmall ? 14 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Supported: JPG, PNG, JPEG",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: isSmall ? 12 : 13,
                    ),
                  ),
                ],
              ),
            ),
          if (_selectedImage != null && !(widget.isLoading ?? false))
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                height: isSmall ? 36 : 45,
                width: isSmall ? 36 : 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1E5B),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: isSmall ? 18 : 20,
                  onPressed: () => _showImageSourceBottomSheet(context),
                  icon: const Icon(Icons.edit),
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return GestureDetector(
      onTap: () => _showImageSourceBottomSheet(context),
      child: widget.mode == PickerMode.avatar
          ? _buildAvatarMode(isSmall)
          : _buildDocumentMode(isSmall),
    );
  }
}
