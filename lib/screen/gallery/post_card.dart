import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screen/gallery/post.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'post.dart';
import '../../provider/post_provider.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final void Function()? onCommentPressed;

  const PostCard({Key? key, required this.post, this.onCommentPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PostProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar + username + more
          ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: post.avatarUrl.isNotEmpty
                  ? NetworkImage(post.avatarUrl)
                  : null,
              child: post.avatarUrl.isEmpty
                  ? Text(post.username[0].toUpperCase())
                  : null,
            ),
            title: Text(
              post.username,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(_timeAgo(post.createdAt)),
            trailing: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => _postOptions(context, post),
                );
              },
            ),
          ),

          AspectRatio(aspectRatio: 4 / 3, child: _buildImage(post.imagePath)),

          // Actions row: like, comment, save
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border),
                  onPressed: () => provider.toggleLike(post.id),
                ),
                SizedBox(width: 4),
                GestureDetector(
                  onTap: onCommentPressed,
                  child: Icon(Icons.mode_comment_outlined),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  ),
                  onPressed: () => provider.toggleSave(post.id),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              '${post.likes} likes',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '${post.username} ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: post.caption,
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),

          if (post.comments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4,
              ),
              child: Text(
                '${post.comments.last.username}: ${post.comments.last.text}',
                style: TextStyle(color: Colors.black54),
              ),
            ),

          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (c, s) => Center(child: CircularProgressIndicator()),
        errorWidget: (c, s, e) => Center(child: Icon(Icons.broken_image)),
      );
    }

    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => Center(child: Icon(Icons.broken_image)),
    );
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  Widget _postOptions(BuildContext context, Post post) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(leading: Icon(Icons.report), title: Text('Laporkan')),
          ListTile(leading: Icon(Icons.share), title: Text('Bagikan')),
          ListTile(
            leading: Icon(Icons.cancel),
            title: Text('Batal'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
