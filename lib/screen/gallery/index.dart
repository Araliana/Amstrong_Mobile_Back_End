import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/gallery_post.dart';
import 'package:flutter_application_1/provider/gallery_provider.dart';
import 'package:flutter_application_1/screen/gallery/add.dart';
import 'package:flutter_application_1/screen/gallery/galleryDelete.dart';
import 'package:provider/provider.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  void initState() {
    super.initState();
    // Gunakan addPostFrameCallback untuk memuat data setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPosts();
    });
  }

  Future<void> _loadPosts() async {
    // Panggil provider untuk memuat data
    await Provider.of<GalleryProvider>(context, listen: false).loadPosts();
  }

  void _openAdd() async {
    // Navigasi ke halaman add
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GalleryAddScreen()),
    );
    // Jika result == true (berhasil add), provider sudah auto-reload,
    // tapi kita bisa panggil lagi untuk memastikan jika perlu.
    if (result == true) {
      // Data sudah di-reload oleh provider, tidak perlu _loadPosts() lagi
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer untuk mendengarkan perubahan pada GalleryProvider
    return Consumer<GalleryProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Gallery'),
            actions: [
              IconButton(
                onPressed: _openAdd,
                icon: Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          body: provider.isLoading && provider.posts.isEmpty
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadPosts,
                  child: provider.posts.isEmpty
                      ? _buildEmptyState()
                      : _buildPostList(provider.posts),
                ),
        );
      },
    );
  }

  // Widget untuk tampilan daftar postingan
  Widget _buildPostList(List<GalleryPost> posts) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildPostCard(post);
      },
    );
  }

  // Widget untuk tampilan "Threads-like"
  Widget _buildPostCard(GalleryPost post) {
    final theme = Theme.of(context);

    // Tentukan icon berdasarkan uploader
    IconData uploaderIcon = post.name == 'Admin'
        ? Icons.shield_outlined
        : Icons.person_outline;
    Color uploaderColor = post.name == 'Admin'
        ? Colors.blueAccent
        : Colors.grey.shade600;

    return Column(
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
                    ? uploaderColor.withOpacity(0.3)
                    : uploaderColor.withOpacity(0.1),
                child: Icon(uploaderIcon, size: 20, color: uploaderColor),
              ),
              SizedBox(width: 10),
              // Nama Uploader
              Text(
                post.name, // "Admin" atau "User"
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Spacer(),
              // Tombol Opsi (Hapus)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: Colors.grey.shade500),
                onSelected: (value) {
                  if (value == 'delete') {
                    // Panggil fungsi hapus dari galleryDelete.dart
                    confirmDeleteGalleryPost(context, post.id!);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red[700]),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red[700])),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Caption / Quote
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            post.quote,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: 12),
        // Gambar Postingan
        if (post.imagePath != null && post.imagePath!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(post.imagePath!),
                width: double.infinity,
                fit: BoxFit.cover,
                // Error handling jika file tidak ditemukan
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
        SizedBox(height: 16),
        // Pembatas antar postingan
        Divider(
          height: 1,
          thickness: 1,
          color: theme.dividerColor.withOpacity(0.1),
        ),
      ],
    );
  }

  // Widget untuk tampilan kosong
  Widget _buildEmptyState() {
    return ListView(
      // Ini membuat "pull-to-refresh" tetap aktif
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Icon(Icons.photo_library_outlined, size: 60, color: Colors.grey[400]),
        SizedBox(height: 16),
        Center(
          child: Text(
            'Belum ada postingan.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
        Center(
          child: Text(
            'Tekan ikon + untuk menambah postingan baru.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}
