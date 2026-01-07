import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
              const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=me')),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: "What's on your mind?", border: InputBorder.none),
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
                  if (controller.text.isNotEmpty) {
                    context.read<CommunityProvider>().addPost(controller.text);
                    controller.clear();
                  }
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
              CircleAvatar(backgroundImage: NetworkImage(post.userAvatar)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(post.timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              TextButton(onPressed: () {}, child: const Text("Follow")),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.postText),
          if (post.imageUrl != null) ...[
            const SizedBox(height: 12),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(post.imageUrl!, fit: BoxFit.cover, width: double.infinity, height: 200),
                ),
                if (post.calories != null)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                      child: Text("AI DETECTED: ${post.calories}", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                icon: Icon(post.isLiked ? Icons.favorite : Icons.favorite_border, color: post.isLiked ? Colors.red : Colors.grey),
                onPressed: () => context.read<CommunityProvider>().toggleLike(post.id),
              ),
              Text("${post.likes}"),
              const SizedBox(width: 20),
              const Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey),
              const SizedBox(width: 5),
              Text("${post.comments}"),
            ],
          )
        ],
      ),
    );
  }
}