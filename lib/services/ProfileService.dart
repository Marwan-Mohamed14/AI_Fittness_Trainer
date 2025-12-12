import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_personal_trainer/models/onboarding_data.dart';

class ProfileService {
  final SupabaseClient supabase= Supabase.instance.client;

  String? getCurrentUserId() {
    final user = supabase.auth.currentUser;
    return user?.id;
  }


  Future<void> saveProfile(OnboardingData data)async{
  final userid=getCurrentUserId();
  if(userid==null){
    throw Exception("User not logged in");
  }
  try{
 print('💾 Saving profile data to Supabase...');
final profileData=data.toJson();
profileData['user_id']=userid;
await supabase.from('profiles').upsert(profileData,onConflict: 'user_id');
  }
  catch (e) {
      print('❌ Error saving profile: $e');
      throw Exception('Failed to save profile: $e');
    }
}

Future<OnboardingData?>getProfile()async{
  final userid=getCurrentUserId();
  if(userid==null){
    throw Exception("User not logged in");
  }
  try{
    print('📥 Fetching profile from Supabase...');
    final response=await supabase.from('profiles').select().eq('user_id',userid).maybeSingle();
if(response==null){
  print('⚠️ No profile found for user $userid');
  return null;
  }
  print('✅ Profile loaded successfully!');
      return OnboardingData.fromJson(response);
    } catch (e) {
      print('❌ Error loading profile: $e');
      return null;
    }
}
}