import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  ThemeMode themeMode = ThemeMode.system;

  void toggleTheme(bool isDark) {
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    update();                     // triggers GetBuilder rebuild
    Get.changeThemeMode(themeMode); // applies globally to all screens
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;
}
