import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';

class PostService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current user ID
  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  /// Get current user name from email
  String getCurrentUserName() {
    final email = _supabase.auth.currentUser?.email;
    if (email != null) {
      return email.split('@').first;
    }
    return 'You';
  }

  /// Create a new post
  Future<Post> createPost({
    required String mediaUrl,
    required String mediaType,
    String? caption,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not logged in');

    try {
      print('📝 Creating post...');

      final response = await _supabase.from('posts').insert({
        'user_id': userId,
        'media_url': mediaUrl,
        'media_type': mediaType,
        'caption': caption,
        'user_name': getCurrentUserName(),
      }).select().single();

      print('✅ Post created');

      return Post.fromJson({
        ...response,
        'user_name': getCurrentUserName(),
        'user_avatar': null, // No avatar
        'likes_count': 0,
        'comments_count': 0,
        'is_liked_by_me': false,
      });
    } catch (e) {
      print('❌ Error creating post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  /// Fetch ALL posts (for Community feed)
  Future<List<Post>> fetchPosts() async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not logged in');

    try {
      print('📥 Fetching all posts...');

      final response = await _supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false);

      print('✅ Fetched ${response.length} posts');

      final List<Post> posts = [];

      for (final postData in response) {
        final postUserId = postData['user_id'];

        final String userName = postData['user_name'] ?? 'FitUser';

        // Get likes count
        final likesResponse = await _supabase
            .from('post_likes')
            .select()
            .eq('post_id', postData['id']);
        
        final likesCount = likesResponse.length;

        // Check if current user liked
        final userLike = await _supabase
            .from('post_likes')
            .select('id')
            .eq('post_id', postData['id'])
            .eq('user_id', userId)
            .maybeSingle();

        posts.add(Post.fromJson({
          ...postData,
          'user_name': userName,
          'user_avatar': null, // No avatar
          'likes_count': likesCount,
          'comments_count': 0,
          'is_liked_by_me': userLike != null,
        }));
      }

      return posts;
    } catch (e) {
      print('❌ Error fetching posts: $e');
      throw Exception('Failed to fetch posts: $e');
    }
  }

  /// Fetch MY posts only (for Account page)
  Future<List<Post>> fetchMyPosts() async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not logged in');

    try {
      print('📥 Fetching my posts...');

      final response = await _supabase
          .from('posts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('✅ Fetched ${response.length} of my posts');

      final List<Post> posts = [];

      for (final postData in response) {
        // Get likes count
        final likesResponse = await _supabase
            .from('post_likes')
            .select()
            .eq('post_id', postData['id']);
        
        final likesCount = likesResponse.length;

        // Check if I liked my own post
        final userLike = await _supabase
            .from('post_likes')
            .select('id')
            .eq('post_id', postData['id'])
            .eq('user_id', userId)
            .maybeSingle();

        posts.add(Post.fromJson({
          ...postData,
          'user_name': postData['user_name'] ?? 'FitUser',      
          'user_avatar': null, // No avatar
          'likes_count': likesCount,
          'comments_count': 0,
          'is_liked_by_me': userLike != null,
        }));
      }

      return posts;
    } catch (e) {
      print('❌ Error fetching my posts: $e');
      throw Exception('Failed to fetch my posts: $e');
    }
  }

  /// Like a post
  Future<void> likePost(String postId) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not logged in');

    try {
      await _supabase.from('post_likes').insert({
        'post_id': postId,
        'user_id': userId,
      });
      print('✅ Post liked');
    } catch (e) {
      print('❌ Error liking post: $e');
      throw Exception('Failed to like post');
    }
  }

  /// Unlike a post
  Future<void> unlikePost(String postId) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not logged in');

    try {
      await _supabase
          .from('post_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
      print('✅ Post unliked');
    } catch (e) {
      print('❌ Error unliking post: $e');
      throw Exception('Failed to unlike post');
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not logged in');

    try {
      await _supabase
          .from('posts')
          .delete()
          .eq('id', postId)
          .eq('user_id', userId);
      print('✅ Post deleted');
    } catch (e) {
      print('❌ Error deleting post: $e');
      throw Exception('Failed to delete post');
    }
  }
}