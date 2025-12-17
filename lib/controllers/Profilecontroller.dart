import 'package:ai_personal_trainer/models/MealData.dart';
import 'package:ai_personal_trainer/services/Ai_plan_service.dart';
import 'package:get/get.dart';
import 'package:ai_personal_trainer/models/onboarding_data.dart';
import 'package:ai_personal_trainer/services/ProfileService.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();
  
  // Observable onboarding data
  final Rx<OnboardingData> onboardingData = OnboardingData().obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load existing profile if available
    loadExistingProfile();
  }

  // Load existing profile from Supabase
  Future<void> loadExistingProfile() async {
    try {
      final existingProfile = await _profileService.getProfile();
      if (existingProfile != null) {
        onboardingData.value = existingProfile;
        print('✅ Loaded existing profile');
      }
    } catch (e) {
      print('⚠️ Could not load existing profile: $e');
    }
  }

  // Save age and move to next screen
  Future<void> saveAge(int age) async {
    isLoading.value = true;
    
    try {
      // Update local data
      onboardingData.value.age = age;
      
      // Save to Supabase
      await _profileService.saveProfile(onboardingData.value);
      
      Get.snackbar(
        'Saved',
        'Age saved successfully!',
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 1),
      );
      
      // Navigate to next screen
      Get.toNamed('/height-screen');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save age: $e',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Save height
  Future<void> saveHeight(int height) async {
    isLoading.value = true;
    
    try {
      onboardingData.value.height = height;
      await _profileService.saveProfile(onboardingData.value);
      
      Get.snackbar(
        'Saved',
        'Height saved successfully!',
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 1),
      );
      
      // Navigate to next screen
      Get.toNamed('/gender-screen');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save height: $e',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Save gender
  Future<void> saveGender(String gender) async {
    isLoading.value = true;
    
    try {
      onboardingData.value.gender = gender;
      await _profileService.saveProfile(onboardingData.value);
      
      Get.snackbar(
        'Saved',
        'Gender saved successfully!',
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 1),
      );
      
      // Navigate to next screen
      Get.toNamed('/workout-screen');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save gender: $e',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Save workout data
  Future<void> saveWorkoutData({
    required String goal,
    required String level,
    required int days,
    required String location,
  }) async {
    isLoading.value = true;
    
    try {
      onboardingData.value.workoutGoal = goal;
      onboardingData.value.workoutLevel = level;
      onboardingData.value.trainingDays = days;
      onboardingData.value.trainingLocation = location;
      
      await _profileService.saveProfile(onboardingData.value);
      
      Get.snackbar(
        'Saved',
        'Workout preferences saved successfully!',
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 1),
      );
      
      // Navigate to next screen (diet screen)
      Get.toNamed('/diet-screen');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save workout data: $e',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update this function in ProfileController
Future<void> saveDietData({
  required String dietPreference,
  required int mealsPerDay,
  required String budget,
  required int currentWeight,
  required int targetWeight,
  List<String>? allergies,
}) async {
  isLoading.value = true;
  
  try {
    // Save diet data to local model
    onboardingData.value.dietPreference = dietPreference;
    onboardingData.value.mealsPerDay = mealsPerDay;
    onboardingData.value.budget = budget;
    onboardingData.value.weight = currentWeight;
    onboardingData.value.targetWeight = targetWeight;
    onboardingData.value.allergies = allergies;
    
    await _profileService.saveProfile(onboardingData.value);
    
    print('✅ Diet data saved to Supabase successfully!');
    
    Get.snackbar(
      'Saved',
      'Diet preferences saved! Generating your plan...',
      backgroundColor: Colors.green.withOpacity(0.7),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
    
    await Future.delayed(Duration(milliseconds: 500));
    
    // 🎯 NOW GENERATE THE AI PLANS
    print('\n🎯 Triggering AI plan generation...\n');
    await generateAiPlans();
    
    // After generating plans, go to home
    // Get.offAllNamed('/home');
    
  } catch (e) {
    print('❌ Error saving diet data: $e');
    Get.snackbar(
      'Error',
      'Failed to save diet data: $e',
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
    );
  } finally {
    isLoading.value = false;
  }
}


Future<void>generateAiPlans() async{
 isLoading.value = true;
 try{
    print('\n🔄 Step 1: Fetching user profile from Supabase...');
    final userprofile = await _profileService.getProfile();
    if(userprofile == null) {
      Get.snackbar(
        'Error',
        'No profile found. Please complete your profile first.',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return;
    }
    print('✅ Profile loaded successfully!');
    print('\n🔄 Step 2: Generating AI plans...');

    final plans = await AiPlanService().generateWeeklyPlan(userprofile);

     print('✅ Step 2 Complete: Plans generated');
    print('\n🎉 SUCCESS! Your personalized plans are ready!\n');

     print('\n🔄 Step 3: Saving plans to Supabase...');
    userprofile.dietPlan = plans['diet'];
    userprofile.workoutPlan = plans['workout'];

    await _profileService.saveProfile(userprofile);
    print('Plans saved to Supabase!');

    
    Get.snackbar(
      'Success!',
      'Your personalized plans are ready! Check the terminal.',
      backgroundColor: Colors.green.withOpacity(0.7),
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
   Get.offAllNamed('/home');
 }catch(e){
   Get.snackbar(
     'Error',
     'Failed to generate AI plans: $e',
     backgroundColor: Colors.red.withOpacity(0.7),
     colorText: Colors.white,
   );

}finally {
    isLoading.value = false;
  }
}
Future<DailyMealPlan?> loadDietPlan()async{
  try{
    print('\n🔄 Loading diet plan from profile...');
    final profile=await _profileService.getProfile();
 if (profile?.dietPlan == null || profile!.dietPlan!.isEmpty) {
      print('⚠️ No diet plan found');
      return null;
    } 
  print('diet plan found, parsing...');
    return DietPlanParser.parseDietPlan(profile.dietPlan!);
  } catch (e) {
    print('❌ Error loading diet plan: $e');
    return null;
  }
}

  
}