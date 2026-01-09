import 'package:supabase_flutter/supabase_flutter.dart';

class ExerciseVideoService {
  final SupabaseClient supabase = Supabase.instance.client;

  String? getCurrentUserId() {
    final user = supabase.auth.currentUser;
    return user?.id;
  }

  // Get video URL for an exercise
  Future<String?> getVideoUrl(String exerciseName) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        print('⚠️ User not logged in');
        return null;
      }

      final response = await supabase
          .from('exercise_videos')
          .select('video_url')
          .eq('user_id', userId)
          .eq('exercise_name', exerciseName.toLowerCase().trim())
          .maybeSingle();

      if (response != null) {
        return response['video_url'] as String?;
      }
      return null;
    } catch (e) {
      print('⚠️ Error getting video URL: $e');
      return null;
    }
  }

  // Save video URL for an exercise
  Future<void> saveVideoUrl(String exerciseName, String videoUrl) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Clean and validate URL
      String cleanUrl = videoUrl.trim();
      // Remove any trailing punctuation or brackets
      cleanUrl = cleanUrl.replaceAll(RegExp(r'[.,;:!?)\]}>]+$'), '');
      
      // Basic validation - must be a YouTube URL
      if (!cleanUrl.contains('youtube.com') && !cleanUrl.contains('youtu.be')) {
        print('⚠️ Invalid YouTube URL for $exerciseName: $cleanUrl');
        return; // Skip saving invalid URLs
      }

      await supabase.from('exercise_videos').upsert({
        'user_id': userId,
        'exercise_name': exerciseName.toLowerCase().trim(),
        'video_url': cleanUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('✅ Video URL saved to Supabase for exercise: $exerciseName');
    } catch (e) {
      print('❌ Error saving video URL to Supabase: $e');
      rethrow;
    }
  }

  // Get all exercise video URLs for current user
  Future<Map<String, String>> getAllVideoUrls() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        print('⚠️ User not logged in');
        return {};
      }

      final response = await supabase
          .from('exercise_videos')
          .select('exercise_name, video_url')
          .eq('user_id', userId);

      final Map<String, String> videoUrls = {};
      
      for (final row in response) {
        videoUrls[row['exercise_name'] as String] = row['video_url'] as String;
      }
      
      return videoUrls;
    } catch (e) {
      print('⚠️ Error getting all video URLs from Supabase: $e');
      return {};
    }
  }
}

