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
    // Use 'response' here
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
  //   Future<bool> hasCompletedOnboarding() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     return prefs.getBool('onboarding_completed') ?? false;
  //   } catch (e) {
  //     return false;
  //   }
  // }
  // Update user email
  Future<void> updateEmail(String newEmail) async {
    // Ensure email is properly trimmed and lowercased
    final trimmedEmail = newEmail.trim().toLowerCase();
    
    // Basic validation - form already validates email format
    if (trimmedEmail.isEmpty) {
      throw Exception('Email cannot be empty');
    }
    
    // Check current user email status
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }
    
    print('🔄 Current user email: ${currentUser.email}');
    print('🔄 Attempting to update email to: $trimmedEmail');
    
    // Don't update if it's the same email
    if (currentUser.email?.toLowerCase() == trimmedEmail) {
      print('⚠️ New email is the same as current email, skipping update');
      return;
    }
    
    try {
      // Try updating the email
      final response = await supabase.auth.updateUser(
        UserAttributes(email: trimmedEmail),
      );
      
      // The email might not be updated immediately if email confirmation is required
      // In that case, Supabase sends a confirmation email to the new address
      print('✅ Email update response: ${response.user?.email}');
      
      // Refresh the session to get updated user data if available
      try {
        await supabase.auth.refreshSession();
        print('✅ Session refreshed successfully');
      } catch (e) {
        // Session refresh might fail if email confirmation is pending
        print('⚠️ Session refresh note: $e');
      }
    } on AuthException catch (e) {
      // Log the full error for debugging
      print('❌ AuthException: statusCode=${e.statusCode}, message=${e.message}');
      
      // Handle specific Supabase auth errors
      String errorMessage = e.message;
      
      // Check error status code for more specific errors
      if (e.statusCode == 'email_already_exists' || 
          e.message.toLowerCase().contains('already registered') || 
          e.message.toLowerCase().contains('already exists') ||
          e.message.toLowerCase().contains('user already registered')) {
        errorMessage = 'This email is already registered to another account';
      } else if (e.message.toLowerCase().contains('invalid') && 
                 e.message.contains(currentUser.email ?? '')) {
        errorMessage = 'Your current email address needs to be verified before you can change it. Please verify your current email first.';
      } else {
        // Pass through the actual Supabase error message
        errorMessage = e.message;
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      print('❌ Unexpected error: $e');
      // Re-throw if it's already a formatted Exception
      if (e is Exception && e.toString().contains('Email cannot be empty')) {
        rethrow;
      }
      throw Exception('Failed to update email: $e');
    }
  }

  // Update user password
  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // Update user username (metadata)
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
