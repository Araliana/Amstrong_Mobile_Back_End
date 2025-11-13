// lib/model/gallery_post.dart
class GalleryPost {
  int? id;
  String name; // Uploader (Admin / User)
  String quote; // Caption
  String? imagePath;
  DateTime? createdAt;

  GalleryPost({
    this.id,
    required this.name,
    required this.quote,
    this.imagePath,
    this.createdAt,
  });

  factory GalleryPost.fromMap(Map<String, dynamic> map) {
    return GalleryPost(
      id: map['id'] as int,
      name: map['name'] as String? ?? '',
      quote: map['quote'] as String? ?? '',
      imagePath: map['imagePath'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'quote': quote,
      'imagePath': imagePath,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}