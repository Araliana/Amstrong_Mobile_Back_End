// lib/provider/gallery_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/model/gallery.dart';
// import 'package:firebase_analytics/firebase_analytics.dart'; // Opsional jika Anda pakai analytics

class GalleryProvider with ChangeNotifier {
  // final FirebaseAnalytics analytics = FirebaseAnalytics.instance; // Opsional
  final List<GalleryPost> posts = [];
  final DBHelper db = DBHelper();
  final Tables galleryTable = Tables.gallery;

  bool isLoading = false;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> loadPosts() async {
    _setLoading(true);
    final res = await db.get(
      galleryTable,
      orderBy: "created_at",
      orderType: OrderType.desc, // Postingan terbaru di atas
    );
    posts
      ..clear()
      ..addAll(res.map((e) => GalleryPost.fromMap(e)).toList());
    _setLoading(false);

    // await analytics.logEvent(name: 'load_gallery', parameters: {'count': posts.length});
  }

  Future<void> addPost({
    required String name, // Admin atau User
    required String quote,
    required String? imagePath,
  }) async {
    _setLoading(true);
    await db.insert(galleryTable, {
      'name': name,
      'quote': quote,
      'img': imagePath,
    });

    await loadPosts(); // Reload data setelah menambah
    _setLoading(false);

    // await analytics.logEvent(name: 'add_gallery_post', parameters: {'name': name});
  }

  Future<void> deletePost(int id) async {
    _setLoading(true);
    await db.delete(galleryTable, id: id);

    await loadPosts(); // Reload data setelah menghapus
    _setLoading(false);

    // await analytics.logEvent(name: 'delete_gallery_post', parameters: {'id': id});
  }
}
