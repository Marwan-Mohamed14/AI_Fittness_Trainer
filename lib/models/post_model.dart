class Post {
  final String id;
  final String userName;
  final String userAvatar;
  final String timeAgo;
  final String postText;
  final String? imageUrl;
  final String? calories;
  int likes;
  int comments;
  bool isLiked;

  Post({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.timeAgo,
    required this.postText,
    this.imageUrl,
    this.calories,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });
}