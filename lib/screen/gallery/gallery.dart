// lib/screens/gallery.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../db/db_helper.dart'; // ubah path import sesuai posisi file db_helper.dart
// Jika kamu menempel class ke db_helper.dart, import tetap sama.
// Pastikan GalleryPost dan DBGalleryHelper tersedia.

import 'add.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<GalleryPost> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
    });
    final posts = await DBGalleryHelper.instance.getPosts();
    setState(() {
      _posts = posts;
      _loading = false;
    });
  }

  Future<void> _onRefresh() async {
    await _loadPosts();
  }

  void _openAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddPostScreen()),
    );
    // Jika add.dart mengembalikan true ketika berhasil, reload data
    if (result == true) {
      await _loadPosts();
    }
  }

  Widget _buildTile(GalleryPost p) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: avatar / preview + name + category
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 64,
                    height: 64,
                    color: Colors.grey[200],
                    child: p.imagePath.startsWith('http')
                        ? Image.network(p.imagePath, fit: BoxFit.cover)
                        : Image.file(File(p.imagePath), fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.broken_image)),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      Text(p.category, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'delete') {
                      await DBGalleryHelper.instance.deletePost(p.id!);
                      _loadPosts();
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'delete', child: Text('Hapus')),
                  ],
                )
              ],
            ),

            SizedBox(height: 12),

            // Quote
            Text(
              p.quote,
              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
        actions: [
          IconButton(onPressed: _openAdd, icon: Icon(Icons.add)),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: _posts.isEmpty
                  ? ListView(
                      // supaya pull-to-refresh tetap bekerja saat kosong
                      children: [
                        SizedBox(height: 120),
                        Icon(Icons.photo_library, size: 60, color: Colors.grey[400]),
                        SizedBox(height: 12),
                        Center(child: Text('Belum ada postingan. Tekan + untuk menambah.')),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _posts.length,
                      itemBuilder: (c, i) {
                        final p = _posts[i];
                        return _buildTile(p);
                      },
                    ),
            ),
    );
  }
}
