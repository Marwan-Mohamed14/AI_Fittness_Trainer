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
      
      // Try to navigate to next screen
      // If route doesn't exist, just show success (data is already saved)
      try {
        Get.toNamed('/gender-screen');
      } catch (navError) {
        // Route doesn't exist yet - that's okay, data is saved
        print('⚠️ Navigation route not found: /gender-screen');
        // You can add the route later or navigate to a different screen
      }
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
      Get.toNamed('/workout-goal-screen');
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

  // Generic save method for any field
  Future<void> saveField(String fieldName, dynamic value, String nextRoute) async {
    isLoading.value = true;
    
    try {
      // Update the field dynamically
      switch (fieldName) {
        case 'age':
          onboardingData.value.age = value as int;
          break;
        case 'height':
          onboardingData.value.height = value as int;
          break;
        case 'gender':
          onboardingData.value.gender = value as String;
          break;
        case 'workoutGoal':
          onboardingData.value.workoutGoal = value as String;
          break;
        case 'workoutLevel':
          onboardingData.value.workoutLevel = value as String;
          break;
        case 'trainingDays':
          onboardingData.value.trainingDays = value as int;
          break;
        case 'weight':
          onboardingData.value.weight = value as int;
          break;
        // Add more cases as needed
      }
      
      await _profileService.saveProfile(onboardingData.value);
      
      Get.snackbar(
        'Saved',
        '$fieldName saved successfully!',
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 1),
      );
      
      // Navigate to next screen
      if (nextRoute.isNotEmpty) {
        Get.toNamed(nextRoute);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save $fieldName: $e',
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