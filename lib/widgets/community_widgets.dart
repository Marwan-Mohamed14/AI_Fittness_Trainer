import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../providers/community_provider.dart';
// IMPORTANT: Import your new comments screen here
import '../screens/community/comments_screen.dart'; 

// --- Create Post Section (The bar at the top of the feed) ---
class CreatePostSection extends StatelessWidget {
  const CreatePostSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showCreatePostDialog(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : const Color(0xFFFAFBFC),
          borderRadius: BorderRadius.circular(15),
          border: !isDark
              ? Border.all(color: Colors.black.withOpacity(0.1), width: 1.5)
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  child: Icon(Icons.person, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "What's on your mind?",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    final provider = context.read<CommunityProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => ChangeNotifierProvider.value(
        value: provider,
        child: const CreatePostDialog(),
      ),
    );
  }
}

// --- Create Post Dialog (The Modal for picking images/captions) ---
class CreatePostDialog extends StatefulWidget {
  const CreatePostDialog({super.key});

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _createPost() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await context.read<CommunityProvider>().createPost(
            imageFile: _selectedImage!,
            caption: _captionController.text.trim().isEmpty ? null : _captionController.text.trim(),
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully! 🎉'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Create Post', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  if (_isUploading)
                    const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    ElevatedButton(
                      onPressed: _selectedImage != null ? _createPost : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Post', style: TextStyle(color: Colors.white)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _captionController,
                maxLines: 3,
                enabled: !_isUploading,
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedImage != null)
                _ResponsivePreviewImage(
                  imageFile: _selectedImage!,
                  onRemove: _isUploading ? null : () => setState(() => _selectedImage = null),
                )
              else
                GestureDetector(
                  onTap: _isUploading ? null : _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: isDark ? theme.colorScheme.surface : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3), width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 48, color: theme.colorScheme.primary),
                        const SizedBox(height: 8),
                        const Text('Tap to add photo'),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Social Post Card (The individual post card in the list) ---
class SocialPostCard extends StatelessWidget {
  final Post post;
  final bool showDelete;
  const SocialPostCard({super.key, required this.post, this.showDelete = false});

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
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                child: Icon(Icons.person, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.userName ?? 'FitUser', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(post.timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              if (showDelete)
                PopupMenuButton<String>(
                  onSelected: (val) => val == 'delete' ? _showDeleteConfirmation(context) : null,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [Icon(Icons.delete_outline, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))]),
                    ),
                  ],
                ),
            ],
          ),
          if (post.caption != null && post.caption!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(post.caption!),
          ],
          const SizedBox(height: 12),
          _ResponsivePostImage(imageUrl: post.mediaUrl),
          const SizedBox(height: 16),
          Row(
            children: [
              // Like Button
              IconButton(
                icon: Icon(post.isLikedByMe ? Icons.favorite : Icons.favorite_border, color: post.isLikedByMe ? Colors.red : Colors.grey),
                onPressed: () => context.read<CommunityProvider>().toggleLike(post.id),
              ),
              Text('${post.likesCount}'),
              const SizedBox(width: 20),
              
              // MODIFIED COMMENT BUTTON: Navigates to CommentsScreen
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(post: post),
                    ),
                  );
                },
              ),
              Text('${post.commentsCount}'),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext cardContext) {
    final provider = cardContext.read<CommunityProvider>();
    showDialog(
      context: cardContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await provider.deletePost(post.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Separate StatefulWidget for responsive post images that rebuilds on orientation change
class _ResponsivePostImage extends StatefulWidget {
  final String imageUrl;

  const _ResponsivePostImage({required this.imageUrl});

  @override
  State<_ResponsivePostImage> createState() => _ResponsivePostImageState();
}

class _ResponsivePostImageState extends State<_ResponsivePostImage> {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final size = MediaQuery.of(context).size;
        final screenHeight = size.height;
        final isLandscape = orientation == Orientation.landscape;
        
        // Calculate image height as percentage of screen height
        double imageHeight;
        if (isLandscape) {
          // Landscape: use smaller percentage
          imageHeight = screenHeight * 0.35;
          imageHeight = imageHeight.clamp(200.0, 400.0);
        } else {
          // Portrait: use larger percentage
          imageHeight = screenHeight * 0.45;
          imageHeight = imageHeight.clamp(250.0, 500.0);
        }
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.contain,
            width: double.infinity,
            height: imageHeight,
            key: ValueKey('${widget.imageUrl}_${orientation.name}_${imageHeight}'), // Force rebuild on orientation change
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: imageHeight,
                color: Colors.grey[300],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stack) => Container(
              height: imageHeight,
              color: Colors.grey[300],
              child: const Icon(Icons.error_outline, size: 48),
            ),
          ),
        );
      },
    );
  }
}

// Separate StatefulWidget for responsive preview images in create post dialog
class _ResponsivePreviewImage extends StatefulWidget {
  final File imageFile;
  final VoidCallback? onRemove;

  const _ResponsivePreviewImage({
    required this.imageFile,
    this.onRemove,
  });

  @override
  State<_ResponsivePreviewImage> createState() => _ResponsivePreviewImageState();
}

class _ResponsivePreviewImageState extends State<_ResponsivePreviewImage> {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final size = MediaQuery.of(context).size;
        final screenHeight = size.height;
        final isLandscape = orientation == Orientation.landscape;
        
        // Calculate image height as percentage of screen height
        double imageHeight;
        if (isLandscape) {
          imageHeight = screenHeight * 0.25;
          imageHeight = imageHeight.clamp(150.0, 300.0);
        } else {
          imageHeight = screenHeight * 0.30;
          imageHeight = imageHeight.clamp(180.0, 350.0);
        }
        
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                widget.imageFile,
                width: double.infinity,
                height: imageHeight,
                fit: BoxFit.cover,
                key: ValueKey('preview_${orientation.name}_${imageHeight}'), // Force rebuild on orientation change
              ),
            ),
            if (widget.onRemove != null)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.6),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}