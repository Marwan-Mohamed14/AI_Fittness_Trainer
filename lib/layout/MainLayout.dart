import 'package:flutter/material.dart';
import '../screens/HomePage.dart';
import '../screens/DietPage.dart';
import '../widgets/bottomNavigation.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomePage(),
    Placeholder(),        // Workout (لسه)
    DietPlanScreen(),
    Placeholder(),        // Settings (لسه)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
