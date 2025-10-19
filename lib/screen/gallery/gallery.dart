import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/post_provider.dart';
import 'post_card.dart';
import 'add.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  void initState() {
    super.initState();
    // seed sample data for demo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).seedSample();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddPostScreen()),
              );
            },
          ),
        ],
      ),

      body: Consumer<PostProvider>(
        builder: (context, provider, _) {
          final posts = provider.posts;
          if (posts.isEmpty)
            return Center(
              child: Text('Belum ada postingan. Tekan + untuk menambahkan.'),
            );
          return RefreshIndicator(
            onRefresh: () async {
              // in real app, re-fetch from backend
              await Future.delayed(Duration(milliseconds: 500));
            },
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, i) {
                final p = posts[i];
                return PostCard(
                  post: p,
                  onCommentPressed: () {
                    _openComments(context, p.id);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _openComments(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return _CommentsSheet(postId: postId);
      },
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final String postId;
  const _CommentsSheet({Key? key, required this.postId}) : super(key: key);

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PostProvider>(context);
    final post = provider.posts.firstWhere((e) => e.id == widget.postId);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: post.comments.length,
                  itemBuilder: (c, i) {
                    final com = post.comments[i];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(com.username[0].toUpperCase()),
                      ),
                      title: Text(com.username),
                      subtitle: Text(com.text),
                      trailing: Text(
                        '${com.createdAt.hour}:${com.createdAt.minute.toString().padLeft(2, '0')}',
                      ),
                    );
                  },
                ),
              ),

              Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Tambahkan komentar...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        final text = _controller.text.trim();
                        if (text.isEmpty) return;
                        // For demo: user info is hardcoded; replace with auth current user
                        provider.addComment(
                          widget.postId,
                          userId: 'me',
                          username: 'Saya',
                          text: text,
                        );
                        _controller.clear();
                      },
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
