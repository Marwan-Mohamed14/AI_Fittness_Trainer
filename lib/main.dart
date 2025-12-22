import 'package:ai_personal_trainer/controllers/Profilecontroller.dart';
import 'package:ai_personal_trainer/layout/MainLayout.dart';
import 'package:ai_personal_trainer/screens/NearbyGymsPage.dart';
import 'package:ai_personal_trainer/screens/UserDataPages/AgeScreen.dart';
import 'package:ai_personal_trainer/screens/UserDataPages/DietQuestionsScreen.dart';
import 'package:ai_personal_trainer/screens/UserDataPages/GenderScreen.dart';
import 'package:ai_personal_trainer/screens/UserDataPages/HeightScreen.dart';
import 'package:ai_personal_trainer/screens/UserDataPages/WorkoutQuestionsScreen.dart';
import 'package:ai_personal_trainer/screens/WorkoutPage.dart';
import 'package:ai_personal_trainer/screens/DailyCheckUpMealsScreen.dart';
import 'package:ai_personal_trainer/screens/DailyCheckUpWorkoutScreen.dart';
import 'package:ai_personal_trainer/screens/DietPage.dart';
import 'package:ai_personal_trainer/screens/SettingsPage.dart';
import 'package:ai_personal_trainer/screens/Auth/loginpage.dart';
import 'package:ai_personal_trainer/screens/Auth/signup.dart';
import 'package:ai_personal_trainer/controllers/themecontroller.dart';
import 'package:ai_personal_trainer/supabase_config.dart';
import 'package:ai_personal_trainer/services/Authservice.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:ai_personal_trainer/controllers/notificationcontroller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  try {
    await SupabaseConfig.initializeSupabase();
  } catch (e) {
    debugPrint("Supabase Initialization Failed: $e");
  }

  Get.put(ProfileController());
  final themeController = Get.put(ThemeController());
    Get.put(ProfileController());
 
  Get.put(NotificationController(), permanent: true);
  // Load theme preference before building app
  await themeController.loadTheme();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? initialRoute;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthAndSetRoute();
  }

  Future<void> _checkAuthAndSetRoute() async {
    final authService = AuthService();
    final user = authService.getCurrentUser();
    
    if (user != null) {
      // User is logged in, check if they have completed onboarding
      try {
        final supabase = SupabaseConfig.client;
        final response = await supabase
            .from('profiles')
            .select('user_id')
            .eq('user_id', user.id)
            .maybeSingle();
        
        final hasProfile = response != null;
        setState(() {
          initialRoute = hasProfile ? '/home' : '/age-screen';
          _isLoading = false;
        });
      } catch (e) {
        // If error checking profile, go to login
        setState(() {
          initialRoute = '/login';
          _isLoading = false;
        });
      }
    } else {
      // User is not logged in
      setState(() {
        initialRoute = '/login';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show loading screen while checking auth
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF0F111A),
          body: Center(
            child: CircularProgressIndicator(
              color: Colors.deepPurple,
            ),
          ),
        ),
      );
    }

    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return ScreenUtilInit(
          designSize: const Size(375, 812), // iPhone X base
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return GetMaterialApp(
              title: 'AI Personal Trainer',
              debugShowCheckedModeBanner: false,

              // 🌞 LIGHT THEME
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                scaffoldBackgroundColor: const Color(0xFFF1F3F8),
                cardColor: const Color(0xFFFAFBFC), // Slightly off-white for better contrast
                colorScheme: const ColorScheme.light(
                  primary: Colors.deepPurple,
                  secondary: Colors.deepPurpleAccent,
                  background: Color(0xFFF1F3F8),
                  surface: Color(0xFFFAFBFC), // Slightly off-white
                  onSurface: Color(0xFF1A1A1A), // Darker black for better readability
                  onBackground: Color(0xFF1A1A1A),
                ),
                textTheme: Typography.material2021().black,
                cardTheme: CardThemeData(
                  color: const Color(0xFFFAFBFC), // Slightly off-white
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.black.withOpacity(0.12), // More visible border
                      width: 1.5, // Thicker border
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                ),
                // Add borders to containers/cards in light mode
                dividerTheme: DividerThemeData(
                  color: Colors.black.withOpacity(0.12), // More visible divider
                  thickness: 1,
                ),
              ),

              // 🌙 DARK THEME
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
                textTheme: Typography.material2021().white,
              ),

              themeMode: themeController.themeMode,

              initialRoute: initialRoute ?? '/login',
            getPages: [
              GetPage(name: '/login', page: () => const LoginPage()),
              GetPage(name: '/signup', page: () => const SignupPage()),
              GetPage(name: '/age-screen', page: () => AgeScreen()),
              GetPage(name: '/height-screen', page: () => const HeightScreen()),
              GetPage(name: '/gender-screen', page: () => const GenderScreen()),
              GetPage(name: '/workout-screen', page: () => const WorkoutQuestionsScreen()),
              GetPage(name: '/diet-screen', page: () => const DietQuestionsScreen()),
              GetPage(name: '/home', page: () => const MainLayout()),
              GetPage(name: '/show-diet-page', page: () => const DietPlanScreen()),
              GetPage(name: '/show-workout-page', page: () => const WorkoutPlanScreen()),
              GetPage(name: '/settings-page', page: () => const SettingsScreen()),
              GetPage(name: '/nearby-gyms-page', page: () => const NearbyGymsScreen()),
              GetPage(name: '/daily-meals', page: () => const DailyCheckupMealsScreen()),
  GetPage(name: '/daily-workout', page: () => const DailyCheckupWorkoutScreen()),

            ],
          );
        },
      );
    },
  );
}

}
