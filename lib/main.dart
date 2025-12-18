import 'package:ai_personal_trainer/controllers/Profilecontroller.dart';
import 'package:ai_personal_trainer/layout/MainLayout.dart';
import 'package:ai_personal_trainer/screens/NearbyGymsPage.dart';
import 'package:ai_personal_trainer/screens/UserDataPages/AgeScreen.dart';
import 'package:ai_personal_trainer/screens/UserDataPages/DietQuestionsScreen.dart';
import 'package:ai_personal_trainer/screens/UserDataPages/GenderScreen.dart';
import 'package:ai_personal_trainer/screens/UserDataPages/HeightScreen.dart';
import 'package:ai_personal_trainer/screens/UserDataPages/WorkoutQuestionsScreen.dart';
import 'package:ai_personal_trainer/screens/WorkoutPage.dart';
import 'package:ai_personal_trainer/screens/DietPage.dart';
import 'package:ai_personal_trainer/screens/SettingsPage.dart';
import 'package:ai_personal_trainer/screens/Auth/loginpage.dart';
import 'package:ai_personal_trainer/screens/Auth/signup.dart';
import 'package:ai_personal_trainer/controllers/themecontroller.dart';
import 'package:ai_personal_trainer/supabase_config.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  try {
    await SupabaseConfig.initializeSupabase();
  } catch (e) {
    debugPrint("Supabase Initialization Failed: $e");
  }

  Get.put(ProfileController());
  Get.put(ThemeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetMaterialApp(
          title: 'AI Personal Trainer',
          debugShowCheckedModeBanner: false,

          // 🌞 LIGHT THEME (IMPROVED)
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,

            scaffoldBackgroundColor: const Color(0xFFF1F3F8),

            cardColor: Colors.white,

            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              secondary: Colors.deepPurpleAccent,
              background: Color(0xFFF1F3F8),
              surface: Colors.white,
            ),

            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),

            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.deepPurple,
              unselectedItemColor: Colors.grey,
            ),

            shadowColor: Colors.black12,

            textTheme: Typography.material2021().black,
          ),

          // 🌙 DARK THEME (PERFECT – NO CHANGES)
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,

            scaffoldBackgroundColor: const Color(0xFF0F111A),

            cardColor: const Color(0xFF1C222E),

            colorScheme: const ColorScheme.dark(
              primary: Colors.deepPurple,
              secondary: Colors.deepPurpleAccent,
              background: Color(0xFF0F111A),
              surface: Color(0xFF1C222E),
            ),

            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0F111A),
              foregroundColor: Colors.white,
              elevation: 0,
            ),

            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF0F111A),
              selectedItemColor: Colors.deepPurple,
              unselectedItemColor: Colors.grey,
            ),

            textTheme: Typography.material2021().white,
          ),

          themeMode: themeController.themeMode,

          initialRoute: '/login',
          getPages: [
            GetPage(name: '/login', page: () => const LoginPage()),
            GetPage(name: '/signup', page: () => const SignupPage()),
            GetPage(name: '/age-screen', page: () => AgeScreen()),
            GetPage(name: '/height-screen', page: () => const HeightScreen()),
            GetPage(name: '/gender-screen', page: () => const GenderScreen()),
            GetPage(
              name: '/workout-screen',
              page: () => const WorkoutQuestionsScreen(),
            ),
            GetPage(
              name: '/diet-screen',
              page: () => const DietQuestionsScreen(),
            ),
            GetPage(name: '/home', page: () => const MainLayout()),
            GetPage(
              name: '/show-diet-page',
              page: () => const DietPlanScreen(),
            ),
            GetPage(
              name: '/show-workout-page',
              page: () => const WorkoutPlanScreen(),
            ),
            GetPage(name: '/settings-page', page: () => const SettingsScreen()),
            GetPage(
              name: '/nearby-gyms-page',
              page: () => const NearbyGymsScreen(),
            ),
          ],
        );
      },
    );
  }
}
