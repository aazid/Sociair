import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ludo/bloc/blocss/postbloc/post_bloc.dart';
import 'package:ludo/bloc/blocss/postbloc/post_event.dart';
import 'package:ludo/model/PostModel.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.person, color: Colors.blue[700]),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      _formatTime(post.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              if (post.author == 'You')
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      context.read<PostBloc>().add(DeletePost(postId: post.id));
                    }
                  },
                ),
            ],
          ),

          SizedBox(height: 12),

          // Post content
          Text(
            post.content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.4,
            ),
          ),

          // Post image (if exists)
          if (post.imagePath != null) ...[
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: post.imagePath!.startsWith('/')
                  ? Image.file(
                      File(post.imagePath!),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported, size: 50),
                        );
                      },
                    )
                  : Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[200],
                      child: Icon(Icons.image, size: 50),
                    ),
            ),
          ],

          SizedBox(height: 12),

          // Post actions
          Row(
            children: [
              InkWell(
                onTap: () =>
                    context.read<PostBloc>().add(LikePost(postId: post.id)),
                child: Row(
                  children: [
                    Icon(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: post.isLiked ? Colors.red : Colors.grey[600],
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${post.likes}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24),
              Row(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Comment',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              Spacer(),
              Icon(Icons.share_outlined, color: Colors.grey[600], size: 20),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
