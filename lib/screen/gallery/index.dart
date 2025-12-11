import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/index.dart';
import 'package:flutter_application_1/model/gallery.dart';
import 'package:flutter_application_1/provider/gallery_provider.dart';
import 'package:go_router/go_router.dart';
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

    return Scaffold(
      body: FutureBuilder(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildLoadingState("Fetching Memo...");
          }

          final memos = galleryProvider.memos;

          return RefreshIndicator(
            onRefresh: () => _loadFuture,
            child: memos.isEmpty
                ? buildEmptyState("Memo", Icons.collections_outlined)
                : _buildPostList(memos),
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

  // Widget untuk tampilan daftar postingan
  Widget _buildPostList(List<Memo> memos) {
    return ListView.builder(
      itemCount: memos.length,
      itemBuilder: (context, index) {
        final memo = memos[index];
        return _buildPostCard(memo);
      },
    );
  }

  // Widget untuk tampilan "Threads-like"
  Widget _buildPostCard(Memo memo) {
    final theme = Theme.of(context);

    // Tentukan icon dan color berdasarkan category
    IconData uploaderIcon;
    Color uploaderColor;

    switch (memo.category.toLowerCase()) {
      case 'bands':
        uploaderIcon = Icons.music_note_outlined;
        uploaderColor = Colors.purple;
        break;
      case 'employees':
        uploaderIcon = Icons.badge_outlined;
        uploaderColor = Colors.blueAccent;
        break;
      case 'customers':
      default:
        uploaderIcon = Icons.person_outline;
        uploaderColor = Colors.grey.shade600;
        break;
    }

    return Opacity(
      opacity: memo.isActive ? 1.0 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                // Avatar/Icon Uploader
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.brightness == Brightness.dark
                      ? uploaderColor.withValues(alpha: 0.3)
                      : uploaderColor.withValues(alpha: 0.1),
                  child: Icon(uploaderIcon, size: 20, color: uploaderColor),
                ),
                SizedBox(width: 10),
                // Nama Uploader
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            memo.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(width: 6),
                          // Badge status aktif
                          if (!memo.isActive)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Nonaktif',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        memo.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer<GalleryProvider>(
                  builder: (context, provider, child) {
                    return PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz, color: Colors.grey.shade500),
                      onSelected: (value) {
                        if (value == 'toggle') {
                          provider.editMemo(
                            name: memo.name,
                            quote: memo.quote,
                            img: memo.img,
                            category: memo.category,
                            id: memo.id,
                            isActive: !memo.isActive,
                          );
                        } else if (value == 'edit') {
                          context.push('/add-edit-gallery', extra: memo.id);
                        } else if (value == 'delete') {
                          showDeleteConfirmation(
                            context,
                            title: "Hapus Postingan",
                            label: memo.name,
                            isLoading: provider.isLoading,
                            onDelete: () async {
                              await provider.deleteMemo(memo.id);
                            },
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(
                                memo.isActive
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: memo.isActive
                                    ? Colors.orange[700]
                                    : Colors.green[700],
                              ),
                              SizedBox(width: 8),
                              Text(
                                memo.isActive ? 'Nonaktifkan' : 'Aktifkan',
                                style: TextStyle(
                                  color: memo.isActive
                                      ? Colors.orange[700]
                                      : Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: Colors.blue[700],
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Edit',
                                style: TextStyle(color: Colors.blue[700]),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.red[700],
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          // Caption / Quote
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              memo.quote,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: 12),
          // Gambar Postingan
          if (memo.img.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  memo.img,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey.shade400,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }
}
