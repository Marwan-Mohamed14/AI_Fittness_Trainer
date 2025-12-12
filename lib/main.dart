import 'package:ai_personal_trainer/screens/UserDataPages/AgeScreen.dart';
import 'package:ai_personal_trainer/screens/UserDataPages/DietQuestionsScreen.dart';
import 'package:ai_personal_trainer/screens/UserDataPages/GenderScreen.dart';
import 'package:ai_personal_trainer/screens/UserDataPages/HeightScreen.dart';
import 'package:ai_personal_trainer/screens/UserDataPages/WorkoutQuestionsScreen.dart';
import 'package:ai_personal_trainer/screens/loginpage.dart';
import 'package:ai_personal_trainer/screens/signup.dart';
import 'package:ai_personal_trainer/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase using the static method
  try {
    await SupabaseConfig.initializeSupabase();
  } catch (e) {
    debugPrint("Supabase Initialization Failed: $e");
    // You can show an error screen or run the app anyway
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AI Personal Trainer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // Set initial route
      initialRoute: '/login',
      
      // Define all routes
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
        ),
        GetPage(
          name: '/signup',
          page: () => const SignupPage(),
        ),
        GetPage(
          name: '/age-screen',
          page: () =>  AgeScreen(),
        ),
        GetPage(
          name: '/height-screen',
          page: () => const HeightScreen(),
        ),
        GetPage(
          name: '/gender-screen',
          page: () => const GenderScreen(),
        ),
        GetPage(
          name: '/workout-screen',
          page: () => const WorkoutQuestionsScreen(),
        ),
        GetPage(
          name: '/diet-screen',
          page: () => const DietQuestionsScreen(),
        ),
        // Add more routes as needed
        // GetPage(
        //   name: '/home',
        //   page: () => const HomePage(),
        // ),
      ],
    );
  }
}