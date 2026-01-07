import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p; // You may need the 'path' package

class StorageService {
  final _supabase = Supabase.instance.client;
  final String _bucketName = 'community_posts'; // Make sure this bucket exists in Supabase

  /// Upload image and return the public URL
  Future<String> uploadImage(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(imageFile.path)}';
      final path = 'posts/$fileName';

      // Upload file to bucket
      await _supabase.storage.from(_bucketName).upload(path, imageFile);

      // Get Public URL
      final String publicUrl = _supabase.storage.from(_bucketName).getPublicUrl(path);
      
      return publicUrl;
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  /// Delete image from storage
  Future<void> deleteImage(String publicUrl) async {
    try {
      // Extract the path from the URL to delete it
      final uri = Uri.parse(publicUrl);
      final pathSegments = uri.pathSegments;
      final path = pathSegments.sublist(pathSegments.indexOf(_bucketName) + 1).join('/');
      
      await _supabase.storage.from(_bucketName).remove([path]);
    } catch (e) {
      // Log error but don't necessarily break the flow
      print('Storage delete error: $e');
    }
  }
}