import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';

class PostService {
  final _supabase = Supabase.instance.client;

  /// Fetch all posts with user metadata
  Future<List<Post>> fetchPosts() async {
    try {
      // Note: This assumes you have a 'posts' table. 
      // In a real app, you might use a View to join user info or handle it via RPC.
      final response = await _supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  /// Create a new post row
  Future<Post> createPost({
    required String mediaUrl,
    required String mediaType,
    String? caption,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _supabase.from('posts').insert({
      'user_id': user.id,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'caption': caption,
      'user_name': user.userMetadata?['username'] ?? 'User',
      'user_avatar': user.userMetadata?['avatar_url'],
    }).select().single();

    return Post.fromJson(response);
  }

  /// Like a post
  Future<void> likePost(String postId) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('likes').insert({
      'post_id': postId,
      'user_id': userId,
    });
  }

  /// Unlike a post
  Future<void> unlikePost(String postId) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('likes')
        .delete()
        .match({'post_id': postId, 'user_id': userId});
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    await _supabase.from('posts').delete().eq('id', postId);
  }
}