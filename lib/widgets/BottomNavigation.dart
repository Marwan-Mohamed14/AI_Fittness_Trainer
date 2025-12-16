import 'package:flutter/material.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: const Color(0xFF0F111A),
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'Workout',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant),
          label: 'Diet',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
