class Post {
  final String id;
  final String userId;
  final String mediaUrl;
  final String mediaType; // 'image' or 'video'
  final String? caption;
  
  final DateTime createdAt;
  
  // Additional fields
  final String? userName;
  final String? userAvatar;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByMe;

  Post({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    required this.mediaType,
    this.caption,
    required this.createdAt,
    this.userName,
    this.userAvatar,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLikedByMe = false,
  });

  // Create Post from Supabase JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      mediaUrl: json['media_url'],
      mediaType: json['media_type'] ?? 'image',
      caption: json['caption'],
      createdAt: DateTime.parse(json['created_at']),
      userName: json['user_name'],
      userAvatar: json['user_avatar'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLikedByMe: json['is_liked_by_me'] ?? false,
    );
  }

  // Convert Post to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper to get time ago string (e.g., "2h ago", "5m ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Copy with method for updating specific fields
  Post copyWith({
    String? id,
    String? userId,
    String? mediaUrl,
    String? mediaType,
    String? caption,
    DateTime? createdAt,
    String? userName,
    String? userAvatar,
    int? likesCount,
    int? commentsCount,
    bool? isLikedByMe,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }
}