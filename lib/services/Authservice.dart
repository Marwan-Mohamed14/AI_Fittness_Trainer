import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_personal_trainer/supabase_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final SupabaseClient supabase = SupabaseConfig.client;

  Future<User?> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
   
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        if (username != null) 'username': username,
      },
    );

    return response.user;
  }
  Future<User?> signIn({required String email, required String password}) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return response.user;
  }
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
  User? getCurrentUser(){
    return supabase.auth.currentUser;
  }
  bool isLoggedin(){
    return supabase.auth.currentUser != null;
  }
   String? getCurrentUserId() {
     return supabase.auth.currentUser?.id;
   }
 
  Future<void> updateEmail(String newEmail) async {
    final trimmedEmail = newEmail.trim().toLowerCase();
    
    if (trimmedEmail.isEmpty) {
      throw Exception('Email cannot be empty');
    }
    
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }
    
    print('🔄 Current user email: ${currentUser.email}');
    print('🔄 Attempting to update email to: $trimmedEmail');
    
    if (currentUser.email?.toLowerCase() == trimmedEmail) {
      print('⚠️ New email is the same as current email, skipping update');
      return;
    }
    
    try {
      final response = await supabase.auth.updateUser(
        UserAttributes(email: trimmedEmail),
      );
      
      
      print('✅ Email update response: ${response.user?.email}');
      
      try {
        await supabase.auth.refreshSession();
        print('✅ Session refreshed successfully');
      } catch (e) {
        print('⚠️ Session refresh note: $e');
      }
    } on AuthException catch (e) {
      print('❌ AuthException: statusCode=${e.statusCode}, message=${e.message}');
      
      String errorMessage = e.message;
      
      if (e.statusCode == 'email_already_exists' || 
          e.message.toLowerCase().contains('already registered') || 
          e.message.toLowerCase().contains('already exists') ||
          e.message.toLowerCase().contains('user already registered')) {
        errorMessage = 'This email is already registered to another account';
      } else if (e.message.toLowerCase().contains('invalid') && 
                 e.message.contains(currentUser.email ?? '')) {
        errorMessage = 'Your current email address needs to be verified before you can change it. Please verify your current email first.';
      } else {
        errorMessage = e.message;
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      print('❌ Unexpected error: $e');
      if (e is Exception && e.toString().contains('Email cannot be empty')) {
        rethrow;
      }
      throw Exception('Failed to update email: $e');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<void> updateUsername(String newUsername) async {
    final currentUser = supabase.auth.currentUser;
    final currentMetadata = currentUser?.userMetadata ?? {};
    final updatedMetadata = Map<String, dynamic>.from(currentMetadata);
    updatedMetadata['username'] = newUsername;
    
    await supabase.auth.updateUser(
      UserAttributes(data: updatedMetadata),
    );
  }
}
