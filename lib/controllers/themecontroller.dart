import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  ThemeMode themeMode = ThemeMode.dark; 
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
          themeMode = ThemeMode.dark; 
        }
      } else {
       
        themeMode = ThemeMode.dark;
        await prefs.setString(_themeKey, 'dark');
      }
      
      Get.changeThemeMode(themeMode);
      update();
    } catch (e) {
      themeMode = ThemeMode.dark;
      Get.changeThemeMode(themeMode);
      update();
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, isDark ? 'dark' : 'light');
    } catch (e) {
    }
    
    update(); 
    Get.changeThemeMode(themeMode); 
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;
}
