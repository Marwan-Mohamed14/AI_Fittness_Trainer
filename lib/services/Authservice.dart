import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_personal_trainer/supabase_config.dart';

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
}
