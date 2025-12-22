import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  /// ================= Hydration Reminder =================
  RxBool hydrationEnabled = false.obs;
  Timer? _hydrationTimer;

  /// Toggle method callable from UI
  void toggleHydration(bool value) {
    hydrationEnabled.value = value;

    if (value) {
      _startHydrationReminder();
    } else {
      _stopHydrationReminder();
    }
  }

  /// Start the hydration reminder timer
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

  /// Stop the hydration reminder timer
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

  /// Show the actual hydration reminder notification
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

  /// Generic top notification helper
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
    super.onClose();
  }

  // ================= Future Reminder Functions =================
  // Add more functions here for Meal, Workout, Sleep, etc.
}
