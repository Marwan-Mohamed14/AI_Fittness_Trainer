import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Authcontroller extends GetxController {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  RxBool isLoading = false.obs;

  final supabase = Supabase.instance.client;

 
  Future<void> signUp() async {
  final username = usernameController.text.trim();
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  if (username.isEmpty || email.isEmpty || password.isEmpty) {
    Get.snackbar(
      "Error",
      "Please fill all fields",
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
    );
    return;
  }

  if (!GetUtils.isEmail(email)) {
    Get.snackbar(
      "Error",
      "Please enter a valid email address",
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
    );
    return;
  }

  if (password.length < 6) {
    Get.snackbar(
      "Error",
      "Password must be at least 6 characters",
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
    );
    return;
  }

  isLoading.value = true;

  try {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {"username": username},
    );

    isLoading.value = false;

    if (response.user != null) {
     

      Get.snackbar(
        "Check Your Email",
        "We sent a verification link to ${response.user!.email}. Please verify before logging in.",
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );

      // Go back to login
      Future.delayed(Duration(milliseconds: 500), () {
        Get.offAllNamed('/login'); // Change to your login route name
      });
    } else {
      Get.snackbar(
        "Error",
        "Signup failed. Please try again.",
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  } on AuthException catch (e) {
    isLoading.value = false;

    String errorMessage = "Signup failed";

    if (e.message.toLowerCase().contains("already registered") ||
        e.message.toLowerCase().contains("user already registered")) {
      errorMessage = "This email is already registered!";
    } else if (e.message.toLowerCase().contains("invalid email")) {
      errorMessage = "Invalid email format";
    } else if (e.message.toLowerCase().contains("password")) {
      errorMessage = "Password requirements not met";
    } else {
      errorMessage = e.message;
    }

    Get.snackbar(
      "Error",
      errorMessage,
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  } catch (e) {
    isLoading.value = false;

    Get.snackbar(
      "Error",
      "An unexpected error occurred",
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
    );
  }
}
 
 Future<void> signIn() async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    Get.snackbar(
      "Error",
      "Please fill all fields",
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
    );
    return;
  }

  if (!GetUtils.isEmail(email)) {
    Get.snackbar(
      "Error",
      "Please enter a valid email address",
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
    );
    return;
  }

  isLoading.value = true;

  try {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    isLoading.value = false;

    if (response.user != null && response.session != null) {
      // Check if email is verified
      if (response.user!.emailConfirmedAt == null) {
        // Sign out the user
        await supabase.auth.signOut();
        
        Get.snackbar(
          "Email Not Verified",
          "Please verify your email first. Check your inbox for the verification link.",
          backgroundColor: Colors.orange.withOpacity(0.7),
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
        return;
      }

      // Email is verified - proceed
      Get.snackbar(
        "Success",
        "Logged in successfully!",
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );
      // Check if onboarding completed
      final hasProfile = await hasCompletedOnboarding();
      
      if (hasProfile) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/age-screen');
      }
    }
  } on AuthException catch (e) {
    isLoading.value = false;

    String errorMessage = "Login failed";

    if (e.message.toLowerCase().contains("invalid login credentials") ||
        e.message.toLowerCase().contains("invalid credentials")) {
      errorMessage = "Invalid email or password!";
    } else if (e.message.toLowerCase().contains("email not confirmed")) {
      errorMessage = "Please verify your email first. Check your inbox.";
    } else if (e.message.toLowerCase().contains("invalid email")) {
      errorMessage = "Invalid email format";
    } else {
      errorMessage = e.message;
    }

    Get.snackbar(
      "Error",
      errorMessage,
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  } catch (e) {
    isLoading.value = false;

    Get.snackbar(
      "Error",
      "An unexpected error occurred",
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
    );
  }
}
  Future<bool>hasCompletedOnboarding() async{
    final user=supabase.auth.currentUser;
    if(user==null){
      return false;
    }
      try {
    final response = await supabase
        .from('profiles')
        .select('user_id')  
        .eq('user_id', user.id)
        .maybeSingle();     

    return response != null;
  } catch (e) {
    print("Error checking profile: $e");
    return false;
  }

  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}