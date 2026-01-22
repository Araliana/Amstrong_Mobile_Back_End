import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/index.dart';
import 'package:flutter_application_1/model/gallery.dart';
import 'package:flutter_application_1/provider/gallery_provider.dart';
import 'package:flutter_application_1/provider/language_provider.dart'; // [IMPORT BARU]
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    final galleryProvider = Provider.of<GalleryProvider>(
      context,
      listen: false,
    );
    _loadFuture = galleryProvider.loadMemos();
  }

  @override
  Widget build(BuildContext context) {
    final galleryProvider = Provider.of<GalleryProvider>(context);
    final lang = Provider.of<LanguageProvider>(context); // [INIT PROVIDER]

    return Scaffold(
      body: FutureBuilder(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // [TRANSLATE] Loading state
            return buildLoadingState(lang.getText('loading_data'));
          }

          final memos = galleryProvider.memos;

          return memos.isEmpty
              // [TRANSLATE] Empty state title
              ? buildEmptyState(
                  lang.getText('gallery_title'),
                  Icons.photo_library_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: memos.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // [TRANSLATE] Header title
                      return buildHeader(
                        lang.getText('gallery_title'),
                        Icons.collections_rounded,
                      );
                    }
                    final memo = memos[index - 1];
                    // [MODIFIED] Pass lang provider to helper function
                    return _buildPolaroidCard(memo, lang);
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () => context.push('/add-edit-gallery'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // [MODIFIED] Menerima parameter LanguageProvider
  Widget _buildPolaroidCard(Memo memo, LanguageProvider lang) {
    final galleryProvider = Provider.of<GalleryProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final dark = themeProvider.getTheme();

    // Tentukan icon dan color berdasarkan category
    IconData categoryIcon;
    Color categoryColor;

    switch (memo.category.toLowerCase()) {
      case 'bands':
        categoryIcon = Icons.music_note_outlined;
        categoryColor = Colors.purple;
        break;
      case 'employees':
        categoryIcon = Icons.badge_outlined;
        categoryColor = Colors.blueAccent;
        break;
      case 'customers':
      default:
        categoryIcon = Icons.person_outline;
        categoryColor = Colors.grey.shade600;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Transform.rotate(
        angle: (memo.id.hashCode % 3 - 1) * 0.02, // Slight random rotation
        child: Container(
          decoration: BoxDecoration(
            color: dark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Polaroid Image Section
              Container(
                padding: const EdgeInsets.all(12),
                child: Stack(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: memo.img.isNotEmpty
                          ? Image.network(
                              memo.img,
                              width: double.infinity,
                              height: 280,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  width: double.infinity,
                                  height: 280,
                                  color: dark ? Colors.grey.shade600 : Colors.grey.shade100,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.brown[400],
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                                progress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: 280,
                                  color: dark ? Colors.grey.shade600 : Colors.grey.shade100,
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.grey.shade400,
                                      size: 60,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: double.infinity,
                              height: 280,
                              color: dark ? Colors.grey.shade600 : Colors.grey.shade100,
                              child: Icon(
                                Icons.photo_library_outlined,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                            ),
                    ),

                    // Status Badge (Top Left) - Always Show
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: memo.isActive ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          // [TRANSLATE] Status Badge
                          memo.isActive
                              ? lang.getText('active')
                              : lang.getText('inactive'),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    // Menu Button (Top Right)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: dark ? Colors.grey.shade300 : Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: PopupMenuButton(
                          icon: Icon(
                            Icons.more_horiz,
                            color: Colors.grey.shade800,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_outlined, size: 20),
                                  const SizedBox(width: 8),
                                  // [TRANSLATE] Menu Edit
                                  Text(lang.getText('edit')),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'toggle',
                              child: Row(
                                children: [
                                  Icon(
                                    memo.isActive
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    // [TRANSLATE] Menu Toggle
                                    memo.isActive
                                        ? lang.getText('deactivate')
                                        : lang.getText('activate'),
                                    style: const TextStyle(
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    // [TRANSLATE] Menu Delete
                                    lang.getText('delete'),
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) async {
                            if (value == 'edit') {
                              context.push('/add-edit-gallery', extra: memo.id);
                            } else if (value == 'toggle') {
                              await galleryProvider.editMemo(
                                name: memo.name,
                                quote: memo.quote,
                                img: memo.img,
                                category: memo.category,
                                id: memo.id,
                                isActive: !memo.isActive,
                              );
                            } else if (value == 'delete') {
                              showDeleteConfirmation(
                                context,
                                // [TRANSLATE] Dialog Delete
                                title: lang.getText('post_title'),
                                label: memo.name,
                                isLoading: galleryProvider.isLoading,
                                onDelete: () async {
                                  await galleryProvider.deleteMemo(memo.id);
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Polaroid Bottom Section (Quote Area)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quote dengan styling aesthetic
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left: BorderSide(color: categoryColor, width: 4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Opening Quote Mark
                          Icon(
                            Icons.format_quote,
                            size: 24,
                            color: categoryColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 8),
                          // Quote Text
                          Text(
                            memo.quote,
                            style: TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade800,
                              height: 1.6,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Closing Quote Mark (aligned right)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.format_quote,
                              size: 24,
                              color: categoryColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Author Info
                    Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: categoryColor.withValues(alpha: 0.1),
                          child: Icon(
                            categoryIcon,
                            size: 18,
                            color: categoryColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Name & Category
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                memo.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: dark ? Colors.white : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                memo.category.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: categoryColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
