import 'dart:io';
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../services/storage_service.dart';

class CommunityProvider extends ChangeNotifier {
  final PostService _postService = PostService();
  final StorageService _storageService = StorageService();

  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize - fetch posts
  CommunityProvider() {
    fetchPosts();
  }

  /// Fetch all posts
  Future<void> fetchPosts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _posts = await _postService.fetchPosts();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new post
  Future<void> createPost({
    required File imageFile,
    String? caption,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Upload image
      final imageUrl = await _storageService.uploadImage(imageFile);

      // Create post in database
      final newPost = await _postService.createPost(
        mediaUrl: imageUrl,
        mediaType: 'image',
        caption: caption,
      );

      // Add to list
      _posts.insert(0, newPost);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Toggle like
  Future<void> toggleLike(String postId) async {
    try {
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index == -1) return;

      final post = _posts[index];

      // Optimistic update
      if (post.isLikedByMe) {
        _posts[index] = post.copyWith(
          isLikedByMe: false,
          likesCount: post.likesCount - 1,
        );
        notifyListeners();
        await _postService.unlikePost(postId);
      } else {
        _posts[index] = post.copyWith(
          isLikedByMe: true,
          likesCount: post.likesCount + 1,
        );
        notifyListeners();
        await _postService.likePost(postId);
      }
    } catch (e) {
      // Revert on error
      await fetchPosts();
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    try {
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index == -1) return;

      final post = _posts[index];

      // Remove from list
      _posts.removeAt(index);
      notifyListeners();

      // Delete from storage
      await _storageService.deleteImage(post.mediaUrl);

      // Delete from database
      await _postService.deletePost(postId);
    } catch (e) {
      await fetchPosts();
      rethrow;
    }
  }

  /// Refresh posts
  Future<void> refreshPosts() async {
    await fetchPosts();
  }
}