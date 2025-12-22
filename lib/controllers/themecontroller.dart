import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  ThemeMode themeMode = ThemeMode.dark; // Default to dark mode
  static const String _themeKey = 'theme_mode';

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      
      if (savedTheme != null) {
        if (savedTheme == 'dark') {
          themeMode = ThemeMode.dark;
        } else if (savedTheme == 'light') {
          themeMode = ThemeMode.light;
        } else {
          themeMode = ThemeMode.dark; // Default to dark
        }
      } else {
        // First time - default to dark
        themeMode = ThemeMode.dark;
        await prefs.setString(_themeKey, 'dark');
      }
      
      Get.changeThemeMode(themeMode);
      update();
    } catch (e) {
      // If error, default to dark
      themeMode = ThemeMode.dark;
      Get.changeThemeMode(themeMode);
      update();
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    
    // Save preference
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, isDark ? 'dark' : 'light');
    } catch (e) {
      // Ignore save errors
    }
    
    update(); // triggers GetBuilder rebuild
    Get.changeThemeMode(themeMode); // applies globally to all screens
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;
}
