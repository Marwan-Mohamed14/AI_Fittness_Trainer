import 'package:flutter/material.dart';
import '../../models/post_model.dart'; // Ensure this matches your path
import '../../utils/responsive.dart';

class CommentsScreen extends StatefulWidget {
  final Post post;
  const CommentsScreen({super.key, required this.post});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();

  // Mock data based on your Comment model provided
  final List<Map<String, dynamic>> _mockComments = [
    {
      'user_name': 'Sarah Chen',
      'content': 'Incredible progress! Your squat depth is looking perfect. Did you adjust your stance?',
      'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'is_assistant': false,
    },
    {
      'user_name': 'FitMind AI',
      'content': 'Analyzing that movement... Your hip hinge looks improved by roughly 15% compared to last week. Keep it up, Alex!',
      'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      'is_assistant': true,
    },
    {
      'user_name': 'Marcus Thorne',
      'content': 'What macro split are you following for this strength phase?',
      'created_at': DateTime.now().subtract(const Duration(minutes: 45)).toIso8601String(),
      'is_assistant': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final padding = Responsive.padding(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Comments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: padding),
              children: [
                _buildOriginalPostHeader(theme),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "RECENT COMMENTS",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                ..._mockComments.map((data) => _CommentTile(
                      userName: data['user_name'],
                      content: data['content'],
                      timeAgo: "2h ago", // Simplified for UI
                      isAssistant: data['is_assistant'],
                    )),
              ],
            ),
          ),
          _buildCommentInputSection(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildOriginalPostHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              child: Icon(Icons.person, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.post.userName ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.post.timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                widget.post.caption ?? "",
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
            const SizedBox(width: 10),
            if (widget.post.mediaUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.post.mediaUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
        const SizedBox(height: 15),
        const Divider(color: Colors.grey, thickness: 0.2),
      ],
    );
  }

  Widget _buildCommentInputSection(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D21) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AI Suggestions Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSuggestionChip("✨ FitMind Suggestion: \"Great work!\"", theme),
                  const SizedBox(width: 8),
                  _buildSuggestionChip("\"What's the routine?\"", theme),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Input Bar
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: const Icon(Icons.person, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF262A30) : const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: "Add a comment...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        suffixIcon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey, size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: () {
                      // Logic to send comment
                      _commentController.clear();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final String userName;
  final String content;
  final String timeAgo;
  final bool isAssistant;

  const _CommentTile({
    required this.userName,
    required this.content,
    required this.timeAgo,
    this.isAssistant = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isAssistant ? Colors.blue : Colors.grey.shade800,
            child: Icon(
              isAssistant ? Icons.bolt : Icons.person, 
              size: 16, 
              color: Colors.white
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 8),
                    if (isAssistant)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text("ASSISTANT", style: TextStyle(color: Colors.blue, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    const SizedBox(width: 8),
                    Text("•  $timeAgo", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.9), fontSize: 14, height: 1.3),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.favorite, size: 16, color: isAssistant ? Colors.blue : Colors.grey),
                    const SizedBox(width: 4),
                    const Text("12", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(width: 20),
                    const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text("Reply", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}