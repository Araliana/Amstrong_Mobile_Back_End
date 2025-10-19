import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../screen/gallery/post.dart';

class PostProvider extends ChangeNotifier {
  final List<Post> _posts = [];
  final Uuid _uuid = Uuid();

  List<Post> get posts => List.unmodifiable(_posts.reversed);

  // Add a new post (imagePath can be local file path or network URL)
  Future<void> addPost({
    required String userId,
    required String username,
    required String avatarUrl,
    required String imagePath,
    required String caption,
  }) async {
    final post = Post(
      id: _uuid.v4(),
      userId: userId,
      username: username,
      avatarUrl: avatarUrl,
      imagePath: imagePath,
      caption: caption,
      createdAt: DateTime.now(),
    );

    _posts.add(post);
    notifyListeners();
  }

  void toggleLike(String postId) {
    final p = _posts.firstWhere((e) => e.id == postId);
    p.likes +=
        1; // for simplicity: every tap adds a like. In real app track user likes.
    notifyListeners();
  }

  void toggleSave(String postId) {
    final p = _posts.firstWhere((e) => e.id == postId);
    p.isSaved = !p.isSaved;
    notifyListeners();
  }

  void addComment(
    String postId, {
    required String userId,
    required String username,
    required String text,
  }) {
    final p = _posts.firstWhere((e) => e.id == postId);
    p.comments.add(
      Comment(
        id: _uuid.v4(),
        userId: userId,
        username: username,
        text: text,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void seedSample() {
    if (_posts.isNotEmpty) return;
    _posts.addAll([
      Post(
        id: _uuid.v4(),
        userId: 'u1',
        username: 'andi',
        avatarUrl: '',
        imagePath: 'https://picsum.photos/600/800?image=10',
        caption: 'Cuaca pagi ini sangat menyegarkan! #pagi',
        createdAt: DateTime.now().subtract(Duration(hours: 3)),
        likes: 5,
        comments: [
          Comment(
            id: _uuid.v4(),
            userId: 'u2',
            username: 'sinta',
            text: 'Keren!',
            createdAt: DateTime.now().subtract(Duration(hours: 2)),
          ),
        ],
      ),

      Post(
        id: _uuid.v4(),
        userId: 'u2',
        username: 'budi',
        avatarUrl: '',
        imagePath: 'https://picsum.photos/600/800?image=20',
        caption: 'Menikmati sore bersama kopi.',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        likes: 12,
      ),
    ]);
    notifyListeners();
  }
}
