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
}
