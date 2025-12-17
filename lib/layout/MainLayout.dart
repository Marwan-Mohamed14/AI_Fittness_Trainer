import 'package:ai_personal_trainer/screens/SettingsPage.dart';
import 'package:flutter/material.dart';
import '../screens/HomePage.dart';
import '../screens/DietPage.dart';
import '../widgets/bottomNavigation.dart';
import'../screens/WorkoutPage.dart';
import 'package:get/get.dart';
import 'package:ai_personal_trainer/controllers/themecontroller.dart';



class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomePage(),
    WorkoutPlanScreen(),        // Workout (لسه)
    DietPlanScreen(),
    SettingsScreen(),        // Settings (لسه)
  ];

  @override
Widget build(BuildContext context) {
  final themeController = Get.find<ThemeController>();

  return Scaffold(
    appBar: AppBar(
      title: const Text('AI Personal Trainer'),
      actions: [
       GetBuilder<ThemeController>(
      builder: (controller) {
        return Switch(
          value: controller.isDarkMode,
          onChanged: controller.toggleTheme,
        );
      },
    ),
      ],
    ),
    body: _screens[_currentIndex],
    bottomNavigationBar: MainBottomNav(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    ),
  );
}

}
