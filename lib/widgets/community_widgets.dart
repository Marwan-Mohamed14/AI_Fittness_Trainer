import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Note: You may need an image picker package like image_picker to get the File
import '../models/post_model.dart';
import '../providers/community_provider.dart';

class CreatePostSection extends StatelessWidget {
  const CreatePostSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = TextEditingController();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(15),
        border: !isDark ? Border.all(color: Colors.black.withOpacity(0.1), width: 1.5) : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=me'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "What's on your mind?",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.image, color: Colors.blue.shade400, size: 20),
                  const SizedBox(width: 15),
                  Icon(Icons.camera_alt, color: Colors.blue.shade400, size: 20),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  // NOTE: In a real app, you would pick a File first.
                  // This is a placeholder logic for the UI.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Select an image to post")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("Post", style: TextStyle(color: Colors.white)),
              )
            ],
          )
        ],
      ),
    );
  }
}

class SocialPostCard extends StatelessWidget {
  final Post post;
  const SocialPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(15),
        border: !isDark ? Border.all(color: Colors.black.withOpacity(0.1), width: 1.5) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(post.userAvatar ?? 'https://i.pravatar.cc/150?u=default'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.userName ?? "User", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(post.timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // Show delete option if it's the user's post
                },
              ),
            ],
          ),
          if (post.caption != null && post.caption!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(post.caption!),
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              post.mediaUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                  color: post.isLikedByMe ? Colors.red : Colors.grey,
                ),
                onPressed: () => context.read<CommunityProvider>().toggleLike(post.id),
              ),
              Text("${post.likesCount}"),
              const SizedBox(width: 20),
              const Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey),
              const SizedBox(width: 5),
              Text("${post.commentsCount}"),
            ],
          )
        ],
      ),
    );
  }
}