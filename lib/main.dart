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
import 'package:ai_personal_trainer/screens/HomePage.dart';
import 'package:ai_personal_trainer/screens/SettingsPage.dart';
import 'package:ai_personal_trainer/screens/Auth/loginpage.dart';
import 'package:ai_personal_trainer/controllers/themecontroller.dart';

import 'package:ai_personal_trainer/screens/Auth/signup.dart';
import 'package:ai_personal_trainer/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Initialize Supabase using the static method
  try {
    await SupabaseConfig.initializeSupabase();
  } catch (e) {
    debugPrint("Supabase Initialization Failed: $e");
    // You can show an error screen or run the app anyway
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

          // 🌞 Light Theme
        theme: ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: Colors.white,  // default background
  textTheme: Typography.material2021().black, // default text
),
darkTheme: ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: Colors.black,
  textTheme: Typography.material2021().white,
),

          // ✅ NOW this line is VALID
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
            GetPage(name: '/diet-screen', page: () => const DietQuestionsScreen()),
            GetPage(name: '/home', page: () => const MainLayout()),
            GetPage(name: '/show-diet-page', page: () => const DietPlanScreen()),
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
