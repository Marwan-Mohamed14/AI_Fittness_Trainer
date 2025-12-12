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

  // Save diet data
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
      onboardingData.value.dietPreference = dietPreference;
      onboardingData.value.mealsPerDay = mealsPerDay;
      onboardingData.value.budget = budget;
      onboardingData.value.weight = currentWeight;
      onboardingData.value.targetWeight = targetWeight;
      onboardingData.value.allergies = allergies;
      
      await _profileService.saveProfile(onboardingData.value);
      
      Get.snackbar(
        'Saved',
        'Diet preferences saved successfully!',
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 1),
      );
      
      // Navigate to home or complete onboarding
      completeOnboarding();
    } catch (e) {
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
  // Complete onboarding and go to home
  Future<void> completeOnboarding() async {
    isLoading.value = true;
    
    try {
      await _profileService.saveProfile(onboardingData.value);
      
      Get.snackbar(
        'Complete',
        'Profile setup completed!',
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
      
      // Navigate to home screen
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to complete onboarding: $e',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}