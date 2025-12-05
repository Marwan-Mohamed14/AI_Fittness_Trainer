import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static late final SupabaseClient client;

  static Future<void> initializeSupabase() async {
    await Supabase.initialize(
      url: 'https://ndrfrhaemcbxvadevfcf.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5kcmZyaGFlbWNieHZhZGV2ZmNmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ4NTU1NDEsImV4cCI6MjA4MDQzMTU0MX0.CaclPioHqDbu8-d8xBTM_K-pg-K4_c8l4PPG5eT4yF8',
    );

    client = Supabase.instance.client;
  }
}
