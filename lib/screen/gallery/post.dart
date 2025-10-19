import 'package:flutter/foundation.dart';


class Post {
final String id;
final String userId;
final String username;
final String avatarUrl; // can be local path or network url
final String imagePath; // local path or network url
final String caption;
final DateTime createdAt;
int likes;
bool isSaved;
final List<Comment> comments;


Post({
required this.id,
required this.userId,
required this.username,
required this.avatarUrl,
required this.imagePath,
required this.caption,
required this.createdAt,
this.likes = 0,
this.isSaved = false,
List<Comment>? comments,
}) : comments = comments ?? [];
}


class Comment {
final String id;
final String userId;
final String username;
final String text;
final DateTime createdAt;


Comment({
required this.id,
required this.userId,
required this.username,
required this.text,
required this.createdAt,
});
}