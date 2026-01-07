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

  CommunityProvider() {
    fetchPosts();
  }

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

  Future<void> createPost({
    required File imageFile,
    String? caption,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. Upload image to Supabase Storage
      final imageUrl = await _storageService.uploadImage(imageFile);

      // 2. Create entry in Supabase Database
      final newPost = await _postService.createPost(
        mediaUrl: imageUrl,
        mediaType: 'image',
        caption: caption,
      );

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

  Future<void> toggleLike(String postId) async {
    try {
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index == -1) return;

      final post = _posts[index];

      // Optimistic UI update using copyWith
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
      // Revert if database call fails
      await fetchPosts();
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index == -1) return;

      final post = _posts[index];
      _posts.removeAt(index);
      notifyListeners();

      await _storageService.deleteImage(post.mediaUrl);
      await _postService.deletePost(postId);
    } catch (e) {
      await fetchPosts();
      rethrow;
    }
  }

  Future<void> refreshPosts() async {
    await fetchPosts();
  }
}