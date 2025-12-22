import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {

  RxBool hydrationEnabled = false.obs;
  Timer? _hydrationTimer;

  RxBool mealEnabled = true.obs;
  RxBool workoutEnabled = true.obs;
  Timer? _mealTimer;
  Timer? _workoutTimer;

  @override
  void onInit() {
    super.onInit();
    _startMealReminder();
    _startWorkoutReminder();
  }
  
  Duration _calculateDelayUntil(int targetHour, int targetMinute) {
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      targetHour,
      targetMinute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    return scheduledTime.difference(now);
  }

void toogleMeal(bool value) {
    mealEnabled.value = value;

    if (value) {
      _startMealReminder();
    } else {
      _stopMealReminder();
    }
  }
  void _startMealReminder() {
    if (_mealTimer != null) return;

    final delay = _calculateDelayUntil(11, 0);
    
    _mealTimer = Timer(delay, () {
      _showMealNotification();
      
      _mealTimer = Timer.periodic(
        const Duration(hours: 24),
        (_) => _showMealNotification(),
      );
    });
  }
  void _stopMealReminder() {
    _mealTimer?.cancel();
    _mealTimer = null;
  }
  void _showMealNotification() {
    if (!mealEnabled.value) return;

    Get.snackbar(
      '🍽️ Meal Time!',
      'dont forget to log your meals today!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 4),
    );
  }
void toogleWorkout(bool value) {
    workoutEnabled.value = value;

    if (value) {
      _startWorkoutReminder();
    } else {
      _stopWorkoutReminder();
    }
  }
  void _startWorkoutReminder() {
    if (_workoutTimer != null) return;

    final delay = _calculateDelayUntil(12, 0);
    
    _workoutTimer = Timer(delay, () {
      _showWorkoutNotification();
      
      _workoutTimer = Timer.periodic(
        const Duration(hours: 24),
        (_) => _showWorkoutNotification(),
      );
    });
  }
  void _stopWorkoutReminder() {
    _workoutTimer?.cancel();
    _workoutTimer = null;
  }
  void _showWorkoutNotification() {
    if (!workoutEnabled.value) return;

    Get.snackbar(
      '🏋️ Workout Time!',
      'adont forget to log your workouts today!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.purple.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 4),
    );
  }








  void toggleHydration(bool value) {
    hydrationEnabled.value = value;

    if (value) {
      _startHydrationReminder();
    } else {
      _stopHydrationReminder();
    }
  }

  void _startHydrationReminder() {
    if (_hydrationTimer != null) return; 

    _hydrationTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _showHydrationSnack(),
    );

    _showTopNotification(
      title: 'Hydration Enabled',
      message: 'Water reminder is ON every 30 Min 💧',
      icon: Icons.water_drop,
      color: Colors.green,
    );
  }

  void _stopHydrationReminder() {
    _hydrationTimer?.cancel();
    _hydrationTimer = null;

    _showTopNotification(
      title: 'Hydration Disabled',
      message: 'Water reminder is OFF 🚫',
      icon: Icons.water_drop_outlined,
      color: Colors.red,
    );
  }

  void _showHydrationSnack() {
    if (!hydrationEnabled.value) return;

    Get.snackbar(
      '💧 Water Reminder',
      'Time to drink water!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 4),
    );
  }

  void _showTopNotification({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: color.withOpacity(0.95),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      icon: Icon(icon, color: Colors.white),
      duration: const Duration(seconds: 2),
    );
  }

 @override
  void onClose() {
    _hydrationTimer?.cancel();
    _mealTimer?.cancel();
    _workoutTimer?.cancel();
    super.onClose();
  }

  
}
