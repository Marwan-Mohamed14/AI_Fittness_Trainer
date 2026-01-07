import 'package:flutter/material.dart';
import '../models/post_model.dart';

class CommunityProvider extends ChangeNotifier {
  // Mock data representing the image provided
  final List<Post> _posts = [
    Post(
      id: '1',
      userName: "Sarah Fit",
      userAvatar: "https://i.pravatar.cc/150?u=sarah",
      timeAgo: "2 hours ago",
      postText: "Trying out the AI-recommended lunch. Packed with protein! 💪🥗 #FitMind #HealthyEating",
      imageUrl: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c",
      calories: "500 KCAL",
      likes: 46,
      comments: 12,
    ),
    Post(
      id: '2',
      userName: "Mike Runner",
      userAvatar: "https://i.pravatar.cc/150?u=mike",
      timeAgo: "5 hours ago",
      postText: "Just crushed a 5k personal best thanks to the interval training plan. 🏃‍♂️💨",
      likes: 120,
      comments: 8,
    ),
  ];

  List<Post> get posts => _posts;

  // Logic to handle liking a post
  void toggleLike(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      if (_posts[index].isLiked) {
        _posts[index].likes--;
      } else {
        _posts[index].likes++;
      }
      _posts[index].isLiked = !_posts[index].isLiked;
      notifyListeners(); // This tells the UI to refresh
    }
  }

  // Logic to add a new text post
  void addPost(String text) {
    _posts.insert(0, Post(
      id: DateTime.now().toString(),
      userName: "You",
      userAvatar: "https://i.pravatar.cc/150?u=me",
      timeAgo: "Just now",
      postText: text,
    ));
    notifyListeners();
  }
}